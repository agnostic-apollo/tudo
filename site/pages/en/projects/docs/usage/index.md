---
page_ref: "@ARK_PROJECT__VARIANT@/agnostic-apollo/tudo/docs/@ARK_DOC__VERSION@/usage/index.md"
---

# tudo Usage Docs

<!-- @ARK_DOCS__HEADER_PLACEHOLDER@ -->

[`tudo`](https://github.com/agnostic-apollo/tudo) stands for *Termux app user do*. It is a wrapper script to execute commands as the `Termux app (u<userid>_a<appid>)` user (like `u0_a100`) in the [Termux] app, like to drop to an interactive shell for any of the [supported shells](#supported-shells), or to execute shell script files or their text passed as an argument. Check the [Help](#help) and [Command Types](#command-types) sections for more info on what type of commands can be run.

Make sure to read the [Worthy Of Note](#worthy-of-note) section, **specially the [RC File Variables](#rc-file-variables) section. This is very important.**

To use `tudo` with [Termux:Tasker] plugin and [RUN_COMMAND Intent], check [Termux:Tasker] `Setup Instructions` section for details on how to set them up. The [Tasker] app or your plugin host app must be granted `com.termux.permission.RUN_COMMAND` permission. The `tudo` script must be installed at `$PREFIX/bin/tudo`. The `allow-external-apps` property must also be set to `true` in `~/.termux/termux.properties` file since the `$PREFIX/bin/tudo` absolute path is outside the `~/.termux/tasker/` directory. For android `>= 10`, the [Termux] app should also be granted `Draw Over Apps` permission so that foreground commands automatically start executing without the user having to manually click the `Termux` notification in the status bar dropdown notifications list for the commands to start. Check [Templates](#templates) section for template tasks that can be run used to run `tudo` from `Termux:Tasker` plugin app and `RUN_COMMAND Intent`.

If you want to run commands as the `root (superuser)` user, check [`sudo`].

### Contents

- [Current Features](#current-features)
- [Help](#help)
- [Command Types](#command-types)
- [Supported Shells](#supported-shells)
- [Command Options](#command-options)
- [Shell Home](#shell-home)
- [Shell RC Files](#shell-rc-files)
- [Shell History Files](#shell-history-files)
- [Modifying Default Values](#modifying-default-values)
- [Examples](#examples)
- [Templates](#templates)
- [Passing Arguments](#passing-arguments)
- [Issues](#issues)
- [Worthy Of Note](#worthy-of-note)
- [Tests](#tests)

---

&nbsp;





## Current Features

- Allows dropping to an interactive shell as the `Termux app` user for any of the supported [Interactive Shells](#interactive-shells) with priority to either termux or android bin and library paths.
- Allows running single commands as the `Termux app` user without having to start an interactive shell including commands in `/system` partition.
- Allows passing of script file paths or script text as arguments for any of the supported [Script Shells](#script-shells) to have them executed as the `Termux app` user without having to create physical script files first for the later case, like in `~/.termux/tasker/` directory for [Termux:Tasker].
- Automatic setup of home directories, `rc` files, `history` files and working directories with proper ownership and permissions.
- Automatic setup of the shell environment and exporting of all required variables including `LD_PRELOAD` so that termux commands work properly, specifically if being run from [Termux:Tasker] or [RUN_COMMAND Intent].
- Provides a lot of [Command Options](#command-options) that are specifically designed for usage with [Termux:Tasker] and the [RUN_COMMAND Intent].

---

&nbsp;





## Help

```
tudo stands for 'Termux app user do'.
It is a wrapper script to execute commands as the
'Termux app (u<userid>_a<appid>)' user in the
Termux app, like to drop to an interactive shell for any
of the supported shells, or to execute shell script files or their
text passed as an argument.


Usage:
  tudo [command_options] su
  tudo [command_options] asu
  tudo [command_options] [-p] <command> [command_args]
  tudo [command_options] -s <core_script> [core_script_args]


Available command_options:
  [ -h | --help ]    Display this help screen.
  [ --help-extra ]   Display more help about how tudo command works.
  [ -q | --quiet ]   Set log level to 'OFF'.
  [ -v | -vv ]       Set log level to 'DEBUG', 'VERBOSE'.
  [ --version ]      Display version.
  [ -a ]             Set priority to android paths for 'path' and
                     'script' command types. The '$PATH' variable will
                     contain all android bin paths followed all termux
                     bin paths. The '$LD_PRELOAD' variable will not be
                     set.
  [ -A ]             Set priority to android paths for 'asu', 'path'
                     and 'script' command types. The '$PATH' variable
                     will contain only '/system/bin' path. The
                     '$LD_PRELOAD' variable will not be set.
  [ -AA ]            Set priority to android paths for 'asu', 'path'
                     and 'script' command types. The '$PATH' variable
                     will contain all android bin paths. The
                     '$LD_PRELOAD' variable will not be set.
  [ -b ]             Go back to last activity after running core_script.
  [ -B ]             Run core_script in background.
  [ -c ]             Clear shell after running core_script.
  [ -d ]             Disable stdin for core_script.
  [ -e ]             Exit early if core_script fails.
  [ -E ]             Exec interactive shell or the path command.
  [ -f ]             Force use temp script file for core_script.
  [ -F ]             Consider core_script to be a path to script file
                     instead of script text.
  [ -H ]             Same tudo post shell home as tudo shell home.
  [ -i ]             Run interactive tudo post shell after running
                     core_script.
  [ -l ]             Go to launcher activtiy after running core_script.
  [ -L ]             Export all existing paths in '$LD_LIBRARY_PATH'
                     variable.
  [ -n ]             Redirect stderr to /dev/null for core_script.
  [ -N ]             Redirect stdout and stderr to /dev/null for
                     core_script.
  [ -o ]             Redirect stderr to stdout for core_script.
  [ -O ]             Redirect stdout to stderr for core_script.
  [ -p ]             Set 'path' as command type [default].
  [ -P ]             Export all existing paths in '$PATH' variable.
  [ -r ]             Parse commands as per RUN_COMMAND intent rules.
  [ -s ]             Set 'script' as command type.
  [ -S ]             Same tudo post shell as tudo shell.
  [ -t ]             Set priority to termux paths for 'path' and
                     'script' command types. The '$PATH' variable will
                     contain all termux bin paths followed all android
                     bin paths. The '$LD_PRELOAD' variable will
                     contain '$TERMUX__PREFIX/lib/libtermux-exec.so'.
  [ -T ]             Set priority to termux paths for 'su', 'path'
                     and 'script' command types. The '$PATH' variable
                     will contain only '$TERMUX__PREFIX/bin' path.
                     The '$LD_PRELOAD' variable will contain
                     '$TERMUX__PREFIX/lib/libtermux-exec.so'.
  [ -TT ]            Set priority to termux paths for 'su', 'path'
                     and 'script' command types. The '$PATH' variable
                     will contain all termux bin paths. The
                     '$LD_PRELOAD' variable will contain
                     '$TERMUX__PREFIX/lib/libtermux-exec.so'.
  [ --comma-alternative=<alternative> ]
                     Comma alternative character to be used for
                     the '-r' option instead of the default.
  [ --dry-run ]
                     Do not execute tudo commands.
  [ --export-paths=<paths> ]
                     Additional paths to export in '$PATH' variable,
                     separated with colons ':'.
  [ --export-ld-lib-paths=<paths> ]
                     Additional paths to export in '$LD_LIBRARY_PATH'
                     variable, separated with colons ':'.
  [ --hold[=<string>] ]
                     Hold tudo from exiting until string is entered,
                     defaults to any character if string is not passed.
  [ --hold-if-fail ]
                     If '--hold' option is passed, then only hold if
                     exit code of tudo does not equal '0'.
  [ --list-interactive-shells ]
                     Display list of supported interactive shells.
  [ --list-script-shells ]
                     Display list of supported script shells.
  [ --no-create-rc ]
                     Do not create rc files automatically.
  [ --no-create-hist ]
                     Do not create history files automatically.
  [ --no-hist ]
                     Do not save history for tudo shell and tudo post
                     shell.
  [ --no-log-args ]
                     Do not log arguments and core_script content
                     when log level is '>= DEBUG'.
  [ --keep-temp ]
                     Do not delete tudo temp directory on exit.
  [ --post-shell=<shell> ]
                     Name or absolute path for tudo post shell.
  [ --post-shell-home=<path> ]
                     Absolute path for tudo post shell home.
  [ --post-shell-options=<options> ]
                     Additional options to pass to tudo post shell.
  [ --post-shell-post-commands=<commands> ]
                     Bash commands to run after tudo post shell.
  [ --post-shell-pre-commands=<commands> ]
                     Bash commands to run before tudo post shell.
  [ --post-shell-stdin-string=<string> ]
                     String to pass as stdin to tudo post shell.
  [ --remove-prev-temp ]
                     Remove temp files and directories created on
                     previous runs of tudo command.
  [ --script-decode ]
                     Consider the core_script as base64
                     encoded that should be decoded before execution.
  [ --script-name=<name> ]
                     Filename to use for the core_script temp file
                     created in '.tudo.temp.XXXXXX' directory instead
                     of 'tudo_script__core_script'.
  [ --script-redirect=<mode/string> ]
                     Core_script redirect mode for stdout and stderr.
  [ --shell=<shell> ]
                     Name or absolute path for tudo shell.
  [ --shell-home=<path> ]
                     Absolute path for tudo shell home.
  [ --shell-options=<options> ]
                     Additional options to pass to tudo shell.
  [ --shell-post-commands=<commands> ]
                     Bash commands to run after tudo shell for script
                     command type.
  [ --shell-pre-commands=<commands> ]
                     Bash commands to run before tudo shell.
  [ --shell-stdin-string=<string> ]
                     String to pass as stdin to tudo shell for script
                     command type.
  [ --sleep=<seconds> ]
                     Sleep for x seconds before exiting tudo.
  [ --sleep-if-fail ]
                     If '--sleep' option is passed, then only sleep if
                     exit code of tudo does not equal '0'.
  [ --su-path=<path> ]
                     Absolute path for su binary to use instead of
                     searching for it in default search paths.
  [ --su-bin-path-add=0|1 ]
                     Whether to append path to su binary directory to
                     '$PATH' exported for android priority.
  [ --title=<title> ]
                     Title for tudo shell terminal.
  [ --work-dir=<path> ]
                     Absolute path for working directory.


Set log level to '>= DEBUG' to get more info when running tudo command.

Pass '--dry-run' option with log level '>= DEBUG' to see the commands
that will be run without actually executing them.

Visit https://github.com/agnostic-apollo/tudo for more help on how
tudo command works.

Supported interactive shells: `bash zsh dash sh fish python ruby pry node perl lua5.2 lua5.3 lua5.4 php python2 ksh`

Supported script shells: `bash zsh dash sh fish python ruby node perl lua5.2 lua5.3 lua5.4 php python2 ksh`


The 'su' command type drops to an interactive shell as the
'Termux app' user for any of the supported interactive
shells. To drop to a 'bash' shell, just run 'tudo su'. The priority
will be set to termux bin and library paths in '$PATH' and
'$LD_LIBRARY_PATH' variables.
Use the '--shell' option to set the interactive shell to use.


The 'asu' command type is the same as 'su' command type but
instead the priority will be set to android bin and library paths in
'$PATH' and '$LD_LIBRARY_PATH' variables.
Use the '--shell' option to set the interactive shell to use. Only
'/system/bin/sh' shell is allowed on Android '< 7' with '-A' and '-AA'
flags.


The 'path' command type runs a single command as the 'Termux app'
user. You can use it just by running 'tudo <command> [command_args]'
where 'command' is the executable you want to run and 'command_args'
are any optional arguments to it. The 'command' will be run within a
'bash' shell.
The 'command' must be an 'absolute' path to an executable, or
'relative' path from the current working directory to an executable
starting starting with './' or '../' (like './script.sh') or the
executable 'basename' in a directory listed in the final '$PATH'
variable that is to be exported by the 'tudo' command depending on
priority set.
The priority is set based on '-a|-A|-AA' or '-t|-T|-TT' flags, and
if flags are not passed, then the priority for bin paths in '$PATH'
variable is given to termux paths followed by android paths if
executable canonical path is under '$TERMUX__ROOTFS' directory,
otherwise to android paths followed by termux paths.


The 'script' command type takes any script text or path to a script
file for any of the supported script shells referred as 'tudo shell',
and executes the script with any optional arguments with the desired
script shell. This can be done by running the
'tudo -s <core_script> [core_script_args]' command.
The 'core_script' will be considered a 'bash' script by default.
The 'core_script' will be passed to the desired shell using
process substitution or after storing the 'core_script' in a temp file
in a temp directory in 'tudo shell' home
'$TMPDIR/.tudo.temp.XXXXXX/tudo_script__core_script' and passing the path to
the desired shell, where 'XXXXXX' is a randomly generated string.
The method is automatically chosen based on the script shell
capabilities. The '-f' option can be used to force the usage of a
script file. The '-F' option can passed so that the 'core_script'
is considered as a path to script file that should be passed to
'tudo shell' directly instead of considering it as a script text.
Use the '--shell' option to set the script shell to use.
Use the '--post-shell' option to set the interactive shell to use if
'-i' option is passed. Only '/system/bin/sh' shell is allowed on
Android '< 7' with '-A' and '-AA' flags.
The priority is given to termux paths unless '-a|-A|-AA' or
'-t|-T|-TT' flags are passed.


Run "exit" command of your shell to exit interactive shells and return
to the termux shell.
```

---

&nbsp;





## Command Types

### `su`

The `su` command type drops to an interactive shell as the `Termux app` user for any of the supported [Interactive Shells](#interactive-shells). `su` stands for *substitute user* which in this case will be the `Termux app` user. To drop to a `bash` shell, just run `tudo su`.

The priority for bin paths in `$PATH` variable is set to `termux` paths followed `android` paths, the same as if [`-t`](#-t) flag was passed. The [`-T`](#-t-1) or [`-TT`](#-tt) flags can be used to change priority. **To have consistent behaviour with shells starts by the Termux app, pass the [`-T`](#-t-1) flag.** Check the [`$PATH` and `$LD_LIBRARY_PATH` Priorities](#path-and-ld_library_path-priorities) section for more info.

If you just use start the [Termux] app to start a foreground terminal session to run `termux` commands, then this command type may not be too useful, especially for usage with `bash` since `Termux app` user being used would be the same as the default. However, you can use this command type to start an interactive shell session for different shells from plugins. `tudo` will also automatically create the `rc` and `history` files for the shell.

Note that `su` is just a command type and does not represent the `su` binary itself. Use the [`path`](#path) command type to run the `tudo -p su [user]` command instead for calling the `su` binary.

## &nbsp;

&nbsp;



### `asu`

The `asu` command type is the same as `su` command type but instead the priority for bin paths in `$PATH` variable is set to `android` paths followed `termux` paths, the same as if [`-a`](#-a) flag was passed. The [`-A`](#-a-1) or [`-AA`](#-aa) flags can be used to change priority. **To have consistent behaviour with shells starts by android [`adb`](https://developer.android.com/tools/adb), pass the [`-AA`](#-aa) flag.** Check the [`$PATH` and `$LD_LIBRARY_PATH` Priorities](#path-and-ld_library_path-priorities) section for more info.

This can also be useful to run commands in `/system` partition since termux does not automatically export those paths in `$PATH` and `$LD_LIBRARY_PATH` and you would normally get `command not found` errors if you attempt to run them.

## &nbsp;

&nbsp;



### `path`

The `path` command type runs a single command as the `Termux app` user within a `bash` shell. You can use it just by running `tudo <command> [command_args]` where `command` is the executable you want to run and `command_args` are any optional arguments you want to pass to it.

The `tudo <command>` will not work if executable to be run does not have proper ownership or executable permissions which allow the `Termux app` user to read or execute it if `tudo` command itself is being run as the `Termux app` user.

The `command` must be an `absolute` path to an executable, or `relative` path from the current working directory to an executable starting with `./` or `../` (like `./script.sh`) or the executable `basename` in a directory listed in the final `$PATH` variable that is to be exported by the `tudo` command depending on priority set. If it is not found, `tudo` will exit with an error.

&nbsp;

The priority for bin paths in `$PATH` variable is set based on ([`-a`](#-a), [`-A`](#-a-1), [`-AA`](#-aa)) or ([`-t`](#-t), [`-T`](#-t-1), [`-TT`](#-tt)) flags. If flags are not passed, then priority is given to `termux` paths followed `android` paths if executable `canonical` path is under `$TERMUX__ROOTFS` directory (like [`-t`](#-t) flag), otherwise to `android` paths followed `termux` paths (like [`-a`](#-a) flag). Check the [`$PATH` and `$LD_LIBRARY_PATH` Priorities](#path-and-ld_library_path-priorities) section for more info.

If `tudo <command>` is executed, like `tudo ls`, and `ls` is found under `$TERMUX__ROOTFS` directory, which it should be since `coreutils` package provides it at `$TERMUX__PREFIX/bin/ls`, then priority will be set to `termux` paths. If `tudo dumpsys` is executed, then priority should be set to `android` paths since it normally exists at `/system/bin/dumpsys`, i.e not under `$TERMUX__ROOTFS` directory as termux does not provide it with a package or as a wrapper around `/system/bin/dumpsys`.

If `tudo -T <command>` is executed with the [`-T`](#-t-1) flag, then it will be ensured that only binaries under `$TERMUX__PREFIX/bin` directory are executed. like `tudo -T ls` should execute `$TERMUX__PREFIX/bin/ls`.

If `tudo -A <command>` is executed with the [`-A`](#-a-1) flag, then it will be ensured that only binaries under `/system/bin` directory are executed. like `tudo -A ls` should execute `/system/bin/ls`.

&nbsp;

You can also use `tudo <command>` even if you are inside of a `tudo su` shell and it will work without having to switch to `tudo asu` or exporting variables to change priority.

You can also run the `tudo -p su [user]` or `tudo -p /path/to/su [user]` commands to call the `su` binary for dropping to a shell for a specific user or even run a command for a specific user, like `tudo -p su -c "logcat" system`. Note that if you do not provide an absolute path to the `su` binary and just run `tudo -p su`, then the termux `su` wrapper script will be called which is stored at `$PREFIX/bin/su` which automatically tries to find the `su` binary and unsets `LD_LIBRARY_PATH` and `LD_PRELOAD` variables. You can check its contents with `cat "$PREFIX/bin/su"`. The variables will be also be unset by the `tudo` script if it detects you are trying to run a `su` binary. The device must of course be rooted and ideally `Termux` must have been granted root permissions by your root manager app like [SuperSU] or [Magisk] for the `su` commands to work. However, it is highly advised that you use [`sudo`] instead of `tudo` for calling the `su` binary so that it sets a different home than the termux home used by `tudo` by default, among other things.

&nbsp;

Check the [`-r`](#-r) command option that can be specifically used with the `path` command type.

## &nbsp;

&nbsp;



### `script`

The `script` command type takes any script text or path to a script file for any of the supported [Script Shells](#script-shells) referred as `tudo shell`, and executes the script with any optional arguments with the desired script shell. This can be done by running the `tudo -s <core_script> [core_script_args]` command. The `core_script` will be considered a `bash` script by default.

&nbsp;

The priority or bin paths in `$PATH` variable is set to `termux` paths followed `android` paths (like [`-t`](#-t) flag), unless ([`-a`](#-a), [`-A`](#-a-1), [`-AA`](#-aa)) or ([`-T`](#-t-1), [`-TT`](#-tt)) flags are passed. Check the [`$PATH` and `$LD_LIBRARY_PATH` Priorities](#path-and-ld_library_path-priorities) section for more info.

If `tudo -sT <core_script>` is executed with the [`-T`](#-t-1) flag, then it will be ensured that only binaries under `$TERMUX__PREFIX/bin` directory are executed. like `tudo -sT 'ls'` should execute `$TERMUX__PREFIX/bin/ls`.

If `tudo -sA <core_script>` is executed with the [`-A`](#-a-1) flag, then it will be ensured that only binaries under `/system/bin` directory are executed. like `tudo -sA 'ls'` should execute `/system/bin/ls`.

&nbsp;

The `script` command type is incredibly useful for usage with termux plugins like [Termux:Tasker] or [RUN_COMMAND Intent]. Such APIs require script files to be created under `$TERMUX__ROOTFS` or `~/.termux/tasker/` directory to be able to execute them, unless using their `stdin` config. It may get inconvenient to create physical script files for each type of command you want to run. These script files are also neither part of backups of plugin host apps like Tasker and require separate backup methods and nor are part of project configs shared with other people or even between your own devices, and so the scripts need to be added manually to the `~/.termux/tasker/` directory on each device. To solve such issues and to dynamically define scripts of different interpreted languages inside your plugin host app like `Tasker` in local variables (all lowercase `%core_script`) of a task and to pass them to `Termux` as arguments instead of creating script files, the `script` command type can be used. The termux environment will also be properly loaded like setting `LD_PRELOAD` etc before running the commands.

&nbsp;

The `core_script` will be passed to the desired shell using [Process Substitution] or after storing the `core_script` in a temp file in a temp directory in `$TMPDIR/.tudo.temp.XXXXXX/tudo_script__core_script` and passing the path to the desired shell, where `XXXXXX` is a randomly generated string. The method is automatically chosen based on the script shell capabilities. The [`-f`](#-f) option can be used to force the usage of a script file. If the temp directory is created, it will be empty other than the `tudo_script__core_script` file and will be unique for each execution of the script, which the script can use for other temporary stuff without having to worry about cleanup since the temp directory will be automatically removed when `tudo` command exits unless [`--keep-temp`](#--keep-temp) is passed. The temp directory path will also be exported in the `$TUDO_SCRIPT__TEMP_DIR` environment variable which can be used by the `core_script`, `post shell` and `--*shell-*-commands` options, like `--shell-pre-commands='cd "$TUDO_SCRIPT__TEMP_DIR"'`. The `$TMPDIR` refers to `${TERMUX__PREFIX:-$PREFIX}/tmp` which the `tmp` directory path for the `Termux` app.

For `bash zsh fish ksh python python2 ruby perl lua5.2 lua5.3 lua5.4`, process substitution is used by default and for `dash sh node php` a file is used. If the usage of process substitution is breaking for some complex scripts of some specific shell, please report the issue.

The [`-F`](#-f-1) option can be passed so that the `core_script` is considered as a path to a script file that should be passed to `tudo shell` directly instead of considering it as a script text.

The `core_script` can optionally not be passed or passed as an empty string so that other "features" of the `script` command type can still be used without calling the script shell.

&nbsp;

It may also be important to automatically open an interactive shell after the `core_script` completes. This can be done by using the  [`-i`](#-i) option along with [`--post-shell*`](#--post-shell) options. The `tudo post shell` can be any of the supported [Interactive Shells](#interactive-shells) and defaults to `bash`. The same shell as the script `tudo shell` can also be used for `tudo post shell` by passing the [`-S`](#-s-1) option as long as the `tudo shell` exists in the list of supported interactive shells. The environment variable `$TUDO_SCRIPT__CORE_SCRIPT_EXIT_CODE` will be exported containing the exit code of the `core_script` before the interactive shell is started. Running an interactive shell will also keep the terminal session open after commands complete which is normally closed automatically when commands are run with the plugin or intents, although the [`--hold`](#--hold) option can also be used for this.

&nbsp;

You can define your own exit traps inside the `core_script`, but **DO NOT** define them outside it with the `--*shell-*-commands` options since `tudo` defines its own trap function `tudo_script__trap` for cleanup, killing child processes and to exit with the trap signal exit code. If you want to handle traps outside the `core_script`, then define a function named `tudo_script__custom_trap` which will automatically be called by `tudo_script__trap`. The function will be sent `TERM`, `INT`, `HUP`, `QUIT` as `$1` for the respective trap signals. For the `EXIT` signal the `$1` will not be passed. Do not `exit` inside the `tudo_script__custom_trap` function. If the `tudo_script__custom_trap` function exits with exit code `0`, then the `tudo_script__trap` will continue to exit with the original trap signal exit code. If it exits with exit code `125` `ECANCELED`, then `tudo_script__trap` will consider that as a cancellation and will just return without running any other trap commands. If any other exit code is returned, then the `tudo_script__trap` will use that as exit code instead of the original trap signal exit code.

&nbsp;

Check the [`-b`](#-b), [`-B`](#-b-1), [`-c`](#-c), [`-d`](#-d), [`-e`](#-e), [`-E`](#-e-1), [`-f`](#-f), [`-F`](#-f-1), [`-l`](#-l), [`-n`](#-n), `N`, [`-o`](#-o), `O`, [`-r`](#-r), [`--remove-prev-temp`](#--remove-prev-temp), [`--keep-temp`](#--keep-temp), [`--shell*`](#--shell), [`--post-shell*`](#--post-shell), [`--script-decode`](#--script-decode), [`--script-redirect`](#--script-redirect), [`--script-name`](#--script-name) command options that can be specifically used with the `script` command type.

---

&nbsp;





## Supported Shells

The `bash` shell is the default interactive and script shell and must exist at `$PREFIX/bin/bash` with ownership and permissions allowing `Termux app` user to read and execute it. The [`--shell`](#--shell) and [`--post-shell`](#--post-shell) options can be used to change the default shells. The `path` command type always uses the `bash` shell and command options are ignored. The shells must have proper ownership or executable permissions set that allows `Termux app` user to read and execute them.

The exported environment variables `$TUDO__SHELL_PS1` and `$TUDO__POST_SHELL_PS1` can be used to change the default `$PS1` values of the shell, provided that the shell uses it. Check the [Modifying Default Values](#modifying-default-values) section for more info on `tudo` environment variables and modifying default values.

&nbsp;



### Interactive Shells

The supported interactive shells are: `bash zsh dash sh fish python ruby pry node perl lua5.2 lua5.3 lua5.4 php python2 ksh`

These shells can be used for the `su` and `asu` command types like `tudo --shell=<shell> su` and `tudo --shell=<shell> asu` and also as post shell for `script` command type when the [`-i`](#-i) option is passed like `tudo -si --post-shell=<shell> <core_script>` to start an interactive shell after script commands complete.

The `bash` shell is automatically chosen as the default interactive shell if the [`--shell`](#--shell) or [`--post-shell`](#--post-shell) options are not passed to set a specific shell. You can pass the name of a shell listed in the supported shells list like `--shell=zsh` or an absolute path like `--shell=/path/to/zsh`. The `$PREFIX/` and `~/` prefixes are also supported, like `$PREFIX/bin/zsh` or `~/zsh`.


For `perl`, the interactive shell is started using `rlwrap`, which must be installed. Use `pkg install rlwrap` to install.

## &nbsp;

&nbsp;



### Script Shells

The supported script shells are: `bash zsh dash sh fish python ruby node perl lua5.2 lua5.3 lua5.4 php python2 ksh`

These shells can be used for the `script` command type like `tudo -s --shell=<shell> <core_script>`.

The `bash` shell is automatically chosen as the default script shell if the [`--shell`](#--shell) option is not passed to set a specific shell. You can pass the name of a shell listed in the supported shells list like `--shell=zsh` or an absolute path like `--shell=/path/to/zsh`. The `$PREFIX/` and `~/` prefixes are also supported, like `$PREFIX/bin/zsh` or `~/zsh`.

---

&nbsp;





## Command Options

The `$PREFIX/` and `~/` prefixes are supported for all command options that take in absolute paths as arguments. The `$PREFIX/` is a shortcut for the termux prefix directory `/data/data/com.termux/files/usr/`. The `~/` is a shortcut for the termux home directory `/data/data/com.termux/files/home/`. Note that if the paths with shortcuts are not surrounded with single quotes, they will expanded by the local shell before being passed to the `tudo` script instead of the `tudo` script manually expanding them. Note that `~/` will expand to the shell or post shell home and not the necessarily the termux home if used inside scripts or the `*-commands` options.

It's the users responsibility to properly quote all arguments passed to command options and also for any values like paths passed inside the arguments, specifically the `*-commands` and `*-options` options, so that whitespace splitting does not occur.

Check [Arguments and Result Data Limits](#arguments-and-result-data-limits) for details on the max size of arguments that you can pass to `tudo` script, specifically the size of `core_script` and its arguments for the `script` command type.



#### `-v`
#### `-vv`

Increase the log level of the `tudo` command. Useful to see script progress and what commands will actually be run. You can also use log level `>= DEBUG` with the [`--dry-run`](#--dry-run) option to see what commands will be run without actually executing them. `tudo` uses log levels (`OFF=0`, `NORMAL=1`, `DEBUG=2`, `VERBOSE=3`) and defaults to `NORMAL=1`, but currently does not log anything at `OFF=0` or `NORMAL=1`. Log level can also be set by exporting an `int` in `$TUDO__LOG_LEVEL` between `0-3`, like `TUDO__LOG_LEVEL=3` to set log level to `VERBOSE=3`.



#### `-q`
#### `--quiet`

Set the log level of the `tudo` command to `OFF=0`.



#### `-a`

Set priority to `android` paths for [`path`](#path) and [`script`](#script) command types. The `$PATH` variable will contain all android bin paths followed all termux bin paths. The `$LD_PRELOAD` variable will not be set. Check the [`$PATH` and `$LD_LIBRARY_PATH` Priorities](#path-and-ld_library_path-priorities) section for more info.



#### `-A`

Set priority to `android` paths for [`asu`](#asu), [`path`](#path) and [`script`](#script) command types. The `$PATH` variable will contain only `/system/bin` path. The `$LD_PRELOAD` variable will not be set. Check the [`$PATH` and `$LD_LIBRARY_PATH` Priorities](#path-and-ld_library_path-priorities) section for more info.



#### `-AA`

Set priority to `android` paths for [`asu`](#asu), [`path`](#path) and [`script`](#script) command types. The `$PATH` variable will contain all android bin paths. The `$LD_PRELOAD` variable will not be set. Check the [`$PATH` and `$LD_LIBRARY_PATH` Priorities](#path-and-ld_library_path-priorities) section for more info.



#### `-b`

Can be used with the `script` command type mainly for when commands are to be run in a foreground terminal session from plugins. This will simulate double back button press once the `core_script` is complete to go to the last activity, first to close keyboard and second to close terminal session. Use this only for short scripts, otherwise the user may have switched from the terminal session to a different app and back buttons simulation would be done inside that app instead.



#### `-B`

Can be used with the `script` command type to run the `core_script` in background with `&` (not the entire `tudo` command). This can be used with the [`-i`](#-i) option or even with the [`--shell-post-commands`](#--shell-post-commands) option. The `pid` of the background process will be available in the `$TUDO_SCRIPT__CORE_SCRIPT_PID` variable. Note that all child processes are killed when `tudo` exits.



#### `-c`

Can be used with the `script` command type mainly for when commands are to be run in a foreground terminal session from plugins and an interactive shell session needs to be opened after the `core_script` is complete with the [`-i`](#-i) option. This will clear the terminal session once the `core_script` is complete.



#### `-d`

Can be used with the `script` command type to disable `stdin` for the `core_script`. This will redirect the `stdin` to `/dev/null` and unset the `$PS1` variable so that the `core_script` can detect that the `stdin` is not available and run the script in a non-interactive mode. If the `core_script` doesn't check if `stdin` is available or not and still attempts to read, it will receive nothing as input or may even cause exceptions in some script shells if `I/O` exceptions are not handled properly. Note that when plugin commands are run in a foreground terminal session, then even though keyboard is not shown, `stdin` is available and can be requested by the script which will then open the keyboard.



#### `-e`

Can be used with the `script` command type to exit early if `core_script` fails due to an exit code other than `0` without running any commands meant to be run after the `core_script` like defined by [`-b`](#-b), [`-c`](#-c), [`-i`](#-i), [`-l`](#-l), [`--post-shell-pre-commands`](#--post-shell-pre-commands) and [`--post-shell-options`](#--post-shell-options) command options. If [`-B`](#-b-1) is passed, then this is ignored.



#### `-E`

`exec` the `su` that runs the final `tudo` `command_type` command. The commands for [`--hold`](#--hold) and  [`--sleep`](#--sleep) options and any other commands that need to be run after the `tudo` `command_type` command will not be run.



#### `-f`

Can be used with the `script` command to force usage of `$TMPDIR/.tudo.temp.XXXXXX/tudo_script__core_script` temp file for storing `core_script` for debugging or if for reason the shell variant doesn't support process substitution and the `tudo` command is automatically trying to use it and is failing. It can also be used to provide a unique temp directory that can be used by the `core_script` which will automatically be deleted after execution.



#### `-F`

Can be used with the `script` command to consider `core_script` as a path to script file that should be passed to `tudo shell` directly instead of considering it as a script text.



#### `-H`

Can be used with the `script` command type with the [`-i`](#-i) option to use the same interactive `tudo post shell` home as the script `tudo shell` home. This is useful for situations like if you are passing a custom path for `tudo shell` home and want to use the same for `tudo post shell` home instead of the default home used by the `tudo` script. So instead of running `tudo -si --shell-home=/path/to/home --post-shell-home=/path/to/home <core_script>`, you can simple run `tudo -siH --shell-home=/path/to/home <core_script>`.



#### `-i`

Can be used with the `script` command to open an interactive shell after the `core_script` completes, optionally specified by [`--post-shell`](#--post-shell) option. If the [`--post-shell`](#--post-shell) option is not passed, then the shell defaults to `bash`.



#### `-l`

Can be used with the `script` command type mainly for when commands are to be run in a foreground terminal session from plugins. This will simulate home button press once the `core_script` is complete to go to the launcher activity.



#### `-L`

Export all the additional paths that already exist in the `$LD_LIBRARY_PATH` variable at the moment `tudo` command is run while running shells, The default paths exported by `tudo` command will still be exported and prefixed before the additional paths. You can also use the [`--shell-pre-commands`](#--shell-pre-commands) and [`--post-shell-pre-commands`](#--post-shell-pre-commands) options to manually export the `$LD_LIBRARY_PATH` variable with a different priority as long as it doesn't break execution of the shells.



#### `-n`

Can be used with the `script` command type to redirect `stderr` to `/dev/null` only for the `core_script` (not the entire `tudo` command). This is a shortcut for `--script-redirect=3`.



#### `-N`

Can be used with the `script` command type to redirect both `stdout` and `stderr` to `/dev/null` only for the `core_script` (not the entire `tudo` command). This is a shortcut for `--script-redirect=4`.



#### `-o`

Can be used with the `script` command type to redirect `stderr` to `stdout` only for the `core_script` (not the entire `tudo` command). This is a shortcut for `--script-redirect=0`.



#### `-O`

Can be used with the `script` command type to redirect `stdout` to `stderr` only for the `core_script` (not the entire `tudo` command). This is a shortcut for `--script-redirect=1`.



#### `-p`

Sets `path` as the command type for `tudo` and is the default command type.



#### `-P`

Export all the additional paths that already exist in the `$PATH` variable at the moment `tudo` command is run while running shells, The default paths exported by `tudo` command will still be exported and prefixed before the additional paths. You can also use the [`--shell-pre-commands`](#--shell-pre-commands) and [`--post-shell-pre-commands`](#--post-shell-pre-commands) options to manually export the `$PATH` variable with a different priority as long as it doesn't break execution of the shells.



#### `-r`

Parse arguments as per `RUN_COMMAND` intent rules. This will by default replace any comma alternate characters `‚` (`#U+201A`, `&sbquo;`, `&#8218;`, `single low-9 quotation mark`) with simple commas `,` (`U+002C`, `&comma;`, `&#44;`, `comma`) found in any `command_args` for the `path` command type and in `core_script` and any `core_script_args` for the `script` command type. They will also be replaced in the [`--hold`](#--hold), [`--post-shell-home`](#--post-shell-home), [`--post-shell-pre-commands`](#--post-shell-pre-commands), [`--post-shell-options`](#--post-shell-options), [`--shell-home`](#--shell-home), [`--shell-pre-commands`](#--shell-pre-commands), [`--shell-post-commands`](#--shell-post-commands), [`--shell-options`](#--shell-options), [`--script-name`](#--script-name), [`--title`](#--title) and [`--work-dir`](#--work-dir) command options passed **after** the [`-r`](#-r) option, so ideally [`-r`](#-r) option should be passed before any of them. You can use a different character that should be replaced using the [`--comma-alternative`](#--comma-alternative) option. Check [Passing Arguments Using RUN_COMMAND Intent](#passing-arguments-using-run_command-intent) section for why this is may be required.



#### `-s`

Sets `script` as the command type for `tudo`.



#### `-S`

Can be used with the `script` command type with the [`-i`](#-i) option to use the same interactive `tudo post shell` as the script `tudo shell` as long as the `tudo shell` exists in the list of supported interactive shells. This is useful for situations like if you are running a `python` script and want to start a `python` interactive shell after the script completes instead of the likely default `bash` shell. So instead of running `tudo -si --shell=python --post-shell=python <core_script>`, you can simple run `tudo -siS --shell=python <core_script>`.



#### `-t`

Set priority to `termux` paths for [`path`](#path) and [`script`](#script) command types. The `$PATH` variable will contain all termux bin paths followed all android bin paths. The `$LD_PRELOAD` variable will contain `$TERMUX__PREFIX/lib/libtermux-exec.so`. Check the [`$PATH` and `$LD_LIBRARY_PATH` Priorities](#path-and-ld_library_path-priorities) section for more info.



#### `-T`

Set priority to `termux` paths for [`su`](#su), [`path`](#path) and [`script`](#script) command types. The `$PATH` variable will contain only `$TERMUX__PREFIX/bin` path. The `$LD_PRELOAD` variable will contain `$TERMUX__PREFIX/lib/libtermux-exec.so`. Check the [`$PATH` and `$LD_LIBRARY_PATH` Priorities](#path-and-ld_library_path-priorities) section for more info.



#### `-TT`

Set priority to `termux` paths for [`su`](#su), [`path`](#path) and [`script`](#script) command types. The `$PATH` variable will contain all termux bin paths. The `$LD_PRELOAD` variable will contain `$TERMUX__PREFIX/lib/libtermux-exec.so`. Check the [`$PATH` and `$LD_LIBRARY_PATH` Priorities](#path-and-ld_library_path-priorities) section for more info.



#### `--comma-alternative`

Set the comma alternative character to be used for the [`-r`](#-r) option instead of the default.



#### `--dry-run`

Enable dry running of the `tudo` script. This will not execute any commands, nor will `rc` files, `history` files or `working directory` passed be created. However, the `tudo shell` home and `$TMPDIR/.tudo.temp.XXXXXX/tudo_script__core_script` file will still be created if `tudo_script__core_script` file needs to be created. It's advisable to also pass the [`-v`](#-v) or [`-vv`](#-vv) options along with this to see script progress and what commands would actually have been run. Passing `--keep-temp` may also be useful.



#### `--export-paths`

Set the additional paths to export in `$PATH` variable, separated with colons `:`. The string passed must not start or end with or contain two consecutive colons `:`. This overrides `$TUDO__ADDITIONAL_PATHS_TO_EXPORT`.



#### `--export-ld-lib-paths`

Set the additional paths to export in `$LD_LIBRARY_PATH` variable, separated with colons `:`. The string passed must not start or end with or contain two consecutive colons `:`. This overrides `$TUDO__ADDITIONAL_LD_LIBRARY_PATHS_TO_EXPORT`.



#### `--hold[=<string>]`

The `--hold[=<string>]` option can be used to make the `tudo` script hold the terminal and not exit until the `string` is entered. The `string` can only contain alphanumeric and punctuation characters without newlines specified by `[:alnum:]` and `[:punct:]` bash regex character classes. If only [`--hold`](#--hold) is passed, then `tudo` will exit after any key is pressed. This is useful for cases where `tudo` is being run in a foreground terminal session, like from plugins and the terminal closes as soon as the `tudo` exits, regardless of if `tudo` failed or was successful without the user getting a chance to see the output.



#### `--hold-if-fail`

Can be used with the [`--hold`](#--hold) option to only hold if exit code of `tudo` does not equal `0`.



#### `--list-interactive-shells`

Display the list of supported [Interactive Shells](#interactive-shells) and exit.



#### `--list-script-shells`

Display the list of supported [Script Shells](#script-shells) and exit.



#### `--no-create-rc`

Disable automatic creation of `rc` files for `tudo shell` and `tudo post shell` if they are missing.



#### `--no-create-hist`

Disable automatic creation of `history` files for `tudo shell` and `tudo post shell` if they are missing.



#### `--no-hist`

Try to disable history loading and saving for `tudo shell` and `tudo post shell` depending on shell capabilities. Not all interactive shells have history support or of disabling it. The history files will also not be created automatically if they are missing.



#### `--no-log-args`

Can be used with the `path` or `script` command type to disable logging of arguments and `core_script` content when log level is `>= DEBUG`. This is useful in cases where the arguments or `core_script` content is too large and it "hides" the other useful log entries due to terminal session output buffer limitations.



#### `--keep-temp`

Disable automatic deletion of the tudo temp directory `$TMPDIR/.tudo.temp.XXXXXX` on exit. This can be used to debug any temp script files created.



#### `--post-shell`

The `--post-shell=<shell>` option can be used with the `script` command type to pass the name or absolute path for `tudo post shell` to be used with the `script` command type and the [`-i`](#-i) option. Only `/system/bin/sh` shell is allowed on Android `< 7` if running `asu`/`script` commands with [`-A`](#-a-1) and [`-AA`](#-aa) flags as Termux shells will have linker errors as `LD_LIBRARY_PATH` will not be set.



#### `--post-shell-home`

The `--post-shell-home=<path>` option can be used with the `script` command type to pass an absolute path for the `tudo post shell` home that overrides the default value.



#### `--post-shell-options`

The `--post-shell-options=<options>` option can be used with the `script` command type to set additional options to pass to `tudo post shell` while starting an interactive shell.



#### `--post-shell-post-commands`

The `--post-shell-post-commands=<commands>` option can be used with the `script` command type to set bash commands to be run after the `tudo post shell` exits.



#### `--post-shell-pre-commands`

The `--post-shell-pre-commands=<commands>` option can be used with the `script` command type to set bash commands to be run before the `tudo post shell` is started. The commands are run after the commands that are run for the  [`--shell-post-commands`](#--shell-post-commands), [`-b`](#-b), [`-l`](#-l) and [`-c`](#-c) options.



#### `--post-shell-stdin-string`

The `--post-shell-stdin-string=<string>` option can be used with the `script` command type to set the string that should be passed as `stdin` to the `tudo post shell` using process substitution or herestring depending on shell capabilities. Some shells when run in interactive mode may automatically exit after running the commands received through `stdin` or may not even accept strings from `stdin`. This option is used for automated testing.



#### `--remove-prev-temp`

Can be used with the `script` command type to remove temp files and directories created on previous runs of `tudo` command that may have been left behind due to `tudo` being killed and not cleanly exiting, or Termux crashing or being killed by android `OOM` killer or the phone rebooting. Although, temp files are created in `$TMPDIR` which is automatically cleared when termux sessions are closed.



#### `--script-decode`

Can be used with the `script` command type so that the `core_script` passed is considered as a `base64` encoded string that should be decoded and stored in temp file. The temp file path is passed to the script shell. This can be useful to pass a script whose normal decoded form contains non `UTF-8` or binary data which if passed directly as an argument may be discarded by the shell if not encoded first since such data cannot be stored in bash variables. If this is passed, then [`-r`](#-r) option processing will be ignored for the `core_script` but not for any arguments.



#### `--script-name`

Can be used with the `script` command type to set the filename to use for the `core_script` temp file created in `$TMPDIR/.tudo.temp.XXXXXX/tudo_script__core_script` directory instead of `tudo_script__core_script`. The temp file path is passed to the script shell if [`-f`](#-f) or [`--script-decode`](#--script-decode) is passed or if the script shell doesn't support process substitution or if `core_script` passed contained non `UTF-8` or binary data.



#### `--script-redirect`

The `--script-redirect=<mode/string>` option can be used with the `script` command type to set the redirect mode or string for `stdout` and `stderr` for the `core_script`. The following modes are supported:  

- `0` redirect `stderr` to `stdout`. This can be used to receive both `stdout` and `stderr` in a synchronized way as `stdout`, like in `%stdout` variable for `Termux:Tasker` plugin app for easier processing of result of commands.  

- `1` redirect `stdout` to `stderr`. This can be used to receive both `stdout` and `stderr` in a synchronized way as `stderr`, like in `%stderr` variable for `Termux:Tasker` plugin app for easier processing of result of commands.  

- `2` redirect `stdout` to `/dev/null`. This can be used to ignore `stdout` output of the `core_script`.  

- `3` redirect `stderr` to `/dev/null`. This can be used to ignore `stderr` output of the `core_script`.  

- `4` redirect `stdout` and `stderr` to `/dev/null`. This can be used to ignore `stdout` and `stderr` output of the `core_script`.  

- `5` redirect `stderr` to `stdout` and `stdout` to `stderr`. This can be used to swap `stdout` and `stderr` output of the `core_script`.  

- `6` redirect `stderr` to `stdout` and `stdout` to `/dev/null`. This can be used to ignore `stdout` and to receive `stderr` output as `stdout` of the `core_script`.  

- `*` else it is considered a string that's appended after the `core_script` and its arguments. This can be used for custom redirection, like redirection to a file and possibly used along with the [`--shell-pre-commands`](#--shell-pre-commands) option if some prep is required.

Note that anything sent to `stdout` and `stderr` outside the `core_script` shell will still be sent to `stdout` and `stderr` and will be received in the `%stdout` and `%stderr` variables for `Termux:Tasker` plugin app, so do not ignore them completely while checking for failures.



#### `--shell`

The `--shell=<shell>` option can be used to pass the name or absolute path for `tudo shell`. For `su` and `asu` command types, this is refers to the interactive shell. For `script` command type, this refers to script shell that should run the `core_script`. For `path` command type, this option is ignored. Only `/system/bin/sh` shell is allowed on Android `< 7` if running `asu`/`script` commands with [`-A`](#-a-1) and [`-AA`](#-aa) flags as Termux shells will have linker errors as `LD_LIBRARY_PATH` will not be set.



#### `--shell-home`

The `--shell-home=<path>` option can be used to pass an absolute path for the `tudo shell` home that overrides the default value.



#### `--shell-options`

The `--shell-options=<options>` option can be used to set additional options to pass to `tudo shell`. For `su` and `asu` command types, these will be passed while starting an interactive shell. For `script` command type, these will be passed while starting the script shell that will be used to passed the `core_script`. For `path` command type, these options are ignored.



#### `--shell-post-commands`

The `--shell-post-commands=<commands>` option can be used with the `script` command type to set bash commands to be run after the `tudo shell` running the `core_script` exits. The commands are run before the commands that are run for the  [`-b`](#-b), [`-l`](#-l), [`-c`](#-c) and [`--post-shell-pre-commands`](#--post-shell-pre-commands) options.



#### `--shell-pre-commands`

The `--shell-pre-commands=<commands>` option can be used to set the bash commands to be run before the `tudo shell` is started. The commands are run after the `cd` command for [`--work-dir`](#--work-dir) is run.



#### `--shell-stdin-string`

The `--shell-stdin-string=<string>` option can be used with the `su` `asu` and `script` command type to set the string that should be passed as `stdin` to the `tudo shell` using process substitution or herestring depending on shell capabilities. Some shells when run in interactive mode may automatically exit after running the commands received through `stdin` or may not even accept strings from `stdin`. This option is used for automated testing.



#### `--sleep`

The `--sleep=<seconds>` option can be used to make the `tudo` script to sleep for `x` seconds before exiting. Seconds can be an integer or floating point number that is passed to the `sleep` command. This is useful for cases where `tudo` is being run in a foreground terminal session, like from plugins and the terminal closes as soon as the `tudo` exits, regardless of if `tudo` failed or was successful without the user getting a chance to see the output.



#### `--sleep-if-fail`

Can be used with the [`--sleep`](#--sleep) option to only sleep if exit code of `tudo` does not equal `0`.



#### `--su-bin-path-add`

The `--su-bin-path-add=0|1` option can be used to define whether to add the path to `su` binary directory to end of `$PATH` exported for `android` priority. Defaults to `0`. This overrides `$TUDO__ADD_SU_BIN_PATH_TO_PATH_VARIABLE`. It is not added for `-A` and `-T` flags and also not for `-TT` flags as the termux `bin` directory contains a [wrapper for `su`](https://github.com/termux/termux-tools/blob/v1.40.4/scripts/su.in), which would be chosen first since its will exist first in the `$PATH`. Check [`su` search paths](#su-search-paths) for more info and `su` binary options requirements.



#### `--su-path`

The `--su-path=<path>` option can be used to set the absolute path for `su` binary to use instead of searching for it in default search paths. This can be used if path is not in search paths or all paths in it should not be checked. This overrides `$TUDO__SU_PATH`. Check [`su` search paths](#su-search-paths) for more info and `su` binary options requirements.



#### `--title`

The `--title=<title>` option can be used to set the title for the foreground terminal session, that is shown in the `termux` sidebar.



#### `--work-dir`

The `--work-dir=<path>` option can be used to set the absolute path for working directory for the `tudo shell`. The `cd` command is run before the commands passed with [`--shell-pre-commands`](#--shell-pre-commands) and [`--post-shell-pre-commands`](#--post-shell-pre-commands) options are run. The directory will be automatically created if missing.

---

&nbsp;





## Shell Home

The default `$HOME` directory for `tudo shell` and `tudo post shell` is termux home `/data/data/com.termux/files/home`. The [`--shell-home`](#--shell-home) and [`--post-shell-home`](#--post-shell-home) options or the exported environment variables `$TUDO__SHELL_HOME` and `$TUDO__POST_SHELL_HOME` can be used to change the default directory. The home directory is the same as termux home directory by default to keep `config`, `rc` and `history` files the same for the `Termux app` user. The home directory should also be owned by the `Termux app` user and have `0700` permission.

Check the [Modifying Default Values](#modifying-default-values) section for more info on `tudo` environment variables and modifying default values.

The home directory must be under the termux files directory `/data/data/com.termux/files/`, and it must not be one of the following directories: `~/.{cache,config,local,termux}` and `$PREFIX/*`.

The home directory is automatically created when `tudo` command is run if it does not exist. The `Termux app` user ownership and `700` permission is also set to it.

---

&nbsp;





## Shell RC Files

The following shell `rc` files are used for different shells depending on if `tudo shell` or `tudo post shell` home is different from termux home or shared. The `rc` files are usually unique for different shells. 

- If the homes are different, then `tudo` shells and `termux` shells will have different `rc` files, stored in their own homes.

- If the homes are shared, then the `tudo` shells and `termux` shells and will share the `rc` files by default, stored in termux home.

- If the homes are shared, you can set the environment variables `$TUDO__SHELL_SHARE_RCFILES_AND_HISTFILES` and `$TUDO__POST_SHELL_SHARE_RCFILES_AND_HISTFILES` to `0` so that if the shell supports it, then different `rc` files will be used, stored in termux home. This will only work if the shell has a [`--rc`](#--rc) param or environment variable for `rc` files, otherwise `tudo` shells and `termux` shells will have to share the same `RCFILE`, implied by `(shared)` and `(hard-coded)` (by the shell) columns.

For shells that do not have `rc` files have their columns set to `-`.


|  Shell  | RCFILE (different home<br>or shared home with env<br>variable set to 1) | RCFILE (shared home<br>with env variable<br> not set to 1) |    Set Method    |
| ------- |:-----------------------:|:-----------------------:|:----------------:|
| bash    | .bashrc                 | .tudo_bashrc            | --rcfile         |
| zsh     | .zshrc                  | *(shared)*              | $ZDOTDIR         |
| dash    | .dashrc                 | .tudo_dashrc            | $ENV             |
| sh      | .shrc                   | .tudo_shrc              | $ENV             |
| fish    | .config/fish/config.fish| *(shared)*              | $XDG_CONFIG_HOME |
| python  | .pythonrc               | .tudo_pythonrc          | $PYTHONSTARTUP   |
| ruby    | .irbrc                  | *(shared)*              | *(hard-coded)*   |
| pry     | .pryrc                  | *(shared)*              | *(hard-coded)*   |
| node    | -                       | -                       | -                |
| perl    | -                       | -                       | -                |
| lua5.2  | -                       | -                       | -                |
| lua5.3  | -                       | -                       | -                |
| lua5.4  | -                       | -                       | -                |
| php     | php.ini                 | .tudo_php.ini           | -c               |
| python2 | .python2rc              | .tudo_python2rc         | $PYTHONSTARTUP   |
| ksh     | .kshrc                  | .tudo_kshrc             | $ENV             |


The `rc` file parent directory is automatically created when `tudo` command is run if it does not exist. The `Termux app` user ownership and `700` permission is also set to it.

The `rc` file is automatically created when `tudo` command is run if it does not exist. The `Termux app` user ownership and `600` permission is also set to it.

The `rc` file parent directory and `rc` file will not be created automatically if [`-no-create-rc`](#-no-create-rc) is passed.

Check the [Modifying Default Values](#modifying-default-values) section for more info on how do modify the `$TUDO__SHELL_SHARE_RCFILES_AND_HISTFILES` and `$TUDO__POST_SHELL_SHARE_RCFILES_AND_HISTFILES` default values.

---

&nbsp;





## Shell History Files


The following shell `history` files are used for different shells depending on if `tudo shell` or `tudo post shell` home is different from termux home or shared. The `history` files are usually unique for different shells.

- If the homes are different, then `tudo` shells and `termux` shells will have different `history` files, stored in their own homes.

- If the homes are shared, then the `tudo` shells and `termux` shells and will share the `history` files by default, stored in termux home.

- If the homes are shared, you can set the environment variables `$TUDO__SHELL_SHARE_RCFILES_AND_HISTFILES` and `$TUDO__POST_SHELL_SHARE_RCFILES_AND_HISTFILES` to `0` so that if the shell supports it, then different `history` files will be used, stored in termux home. This will only work if the shell has an environment variable for `history` files, otherwise `tudo` shells and `termux` shells will have to share the same `HISTFILE`, implied by `(shared)` and `(hard-coded)` (by the shell) columns.

For shells that do not have `history` files have their columns set to `-`. For shells whose history cannot be disabled have their `Disable Method` column set to `(not possible)`.

For `pry` shell, the existing history will still be loaded, but new history will not be saved.


|  Shell  | HISTFILE (different home<br>or shared home with env<br>variable set to 1) | HISTFILE (shared home<br>with env variable<br> not set to 1) |          Set Method         |          Disable Method             |
| ------- |:-----------------------------:|:----------------------------------:|:---------------------------:|:-----------------------------------:|
| bash    | .bash_history                 | .tudo_bash_history                 | $HISTFILE                   | HISTFILE="/dev/null"                |
| zsh     | .zsh_history                  | .tudo_zsh_history                  | $HISTFILE                   | HISTFILE="/dev/null"                |
| dash    | .dash_history                 | .tudo_dash_history                 | $HISTFILE                   | HISTFILE="/dev/null"                |
| sh      | .sh_history                   | .tudo_sh_history                   | $HISTFILE                   | HISTFILE="/dev/null"                |
| fish    | .local/share/fish/fish_history| .local/share/fish/tudo_fish_history| $fish_history               | --private                           |
| python  | .python_history               | *(shared)*                         | *(hard-coded)*              | readline.write_history_file = *None |
| ruby    | .irb_history                  | *(shared)*                         | *(hard-coded)*              | *(not possible)*                    |
| pry     | .pry_history                  | *(shared)*                         | *(hard-coded)*              | Pry.config.history_save = false     |
| node    | .node_history                 | .tudo_node_history                 | $NODE_REPL_HISTORY          | NODE_REPL_HISTORY=""                |
| perl    | .perl_history                 | .tudo_perl_history                 | `rlwrap` --history-filename | --history-filename "/dev/null"      |
| lua5.2  | -                             | -                                  | -                           | -                                   |
| lua5.3  | -                             | -                                  | -                           | -                                   |
| lua5.4  | -                             | -                                  | -                           | -                                   |
| php     | .php_history                  | *(shared)*                         | *(hard-coded)*              | *(not possible)*                    |
| python2 | -                             | -                                  | -                           | -                                   |
| ksh     | .ksh_history                  | .tudo_ksh_history                  | $HISTFILE                   | HISTFILE="/dev/null"                |


The `history` file parent directory is automatically created when `tudo` command is run if it does not exist. The `Termux app` user ownership and `700` permission is also set to it.

The `history` file is automatically created when `tudo` command is run if it does not exist. The `Termux app` user ownership and `600` permission is also set to it.

The `history` file parent directory and `history` file will not be created automatically if [`-no-create-hist`](#-no-create-hist) or [`--no-hist`](#--no-hist) is passed.

Check the [Modifying Default Values](#modifying-default-values) section for more info on how do modify the `$TUDO__SHELL_SHARE_RCFILES_AND_HISTFILES` and `$TUDO__POST_SHELL_SHARE_RCFILES_AND_HISTFILES` default values.

---

&nbsp;





## Modifying Default Values

Check the [tudo.config](https://github.com/agnostic-apollo/tudo/blob/master/tudo.config) file to see the environment variables that can be used to change the default values. If the `tudo.config` file exits at `~/.config/tudo/tudo.config`, then `tudo` will automatically source it whenever it is run. It must have `Termux app` user ownership or be readable by it.

You can download it from the `master` branch and set it up by running the following commands. If you are on an older version, you may want to extract it from its [release](https://github.com/agnostic-apollo/tudo/releases) instead.

```shell
config_directory=~/.config/tudo
mkdir -p "$config_directory" && \
chmod 700 -R "$config_directory" && \
curl -L 'https://github.com/agnostic-apollo/tudo/raw/master/tudo.config' -o "$config_directory/tudo.config" && \
chmod 600 "$config_directory/tudo.config"
```

If you installed `tudo` with a Termux package manager, like with the `apt`/`pkg` command, then you can also copy it from the on-device examples directory for `tudo`.

```shell
config_directory=~/.config/tudo
mkdir -p "$config_directory" && \
chmod 700 -R "$config_directory" && \
cp "${TERMUX__PREFIX:-$PREFIX}/share/doc/tudo/examples/tudo.config" "$config_directory/tudo.config" && \
chmod 600 "$config_directory/tudo.config"
```

You can use `shell` based text editors like `nano`, `vim` or `emacs` to modify the `tudo.config` file.

`nano ~/.config/tudo/tudo.config`

You can also use `GUI` based text editor android apps that support `SAF`. Termux provides a [Storage Access Framework (SAF)](https://wiki.termux.com/wiki/Internal_and_external_storage) file provider to allow other apps to access its `~/` home directory. However, the `$PREFIX/` directory is not accessible to other apps. The [QuickEdit] or [QuickEdit Pro] app does support `SAF` and can handle large files without crashing, however, it is closed source and its pro version without ads is paid. You can also use [Acode editor] or [Turbo Editor] if you want an open source app.

Note that the android default `SAF` `Document` file picker may not support hidden file or directories like `~/.config` which start with a dot `.`, so if you try to use it to open files for a text editor app, then that directory will not show. You can instead create a symlink for  `~/.config` at `~/config_sym` so that it is shown. Use `ln -s ~/.config ~/config_sym` to create it.

&nbsp;

If you use the `bash` shell in termux terminal session, you can optionally export the environment variables like `$TUDO__SHELL_HOME` and `$TUDO__POST_SHELL_HOME` in the `~/.bashrc` file by adding `export TUDO__SHELL_HOME="/path/to/home"` and `export TUDO__POST_SHELL_HOME="/path/to/home"` lines to it so that they are automatically set whenever you start a terminal session. However, the `~/.bashrc` and `rc` files of other shells will not be sourced if you are running commands from `Termux:Tasker` or `RUN_COMMAND Intent`, and so it is advisable to use the `tudo.config` file instead, which will be sourced in all cases, regardless of how `tudo` is run.

Note that `$TUDO__SHELL_PS1` and `$TUDO__POST_SHELL_PS1` values will not work if `$PS1` variable is overridden in `rc` files in `$PREFIX/etc/` or in `tudo shell` and `tudo post shell` homes. Check [RC File Variables](#rc-file-variables) section for more details.

&nbsp;

The following variables will be available when the `tudo-config` file is sourced.

- `$TUDO__TERMUX_ROOTFS` for the Termux rootfs (`$TERMUX__ROOTFS`).
- `$TUDO__TERMUX_HOME` for the Termux home (`$TERMUX__HOME`), not the `tudo` shell home.
- `$TUDO__TERMUX_PREFIX` for the Termux prefix (`$TERMUX__PREFIX`).

---

&nbsp;





## Examples

If you are using a foreground terminal session, then you must disable the `bash` command completion and history expansion for the current terminal session before running `tudo` commands to pass multi-line arguments by running `bind 'set disable-completion on'; set +H`. Otherwise `bash` will try to auto complete commands and search the history, and you will get prompts like `Display all x possibilities? (y or n)`.

&nbsp;



### `su`

- Drop to an interactive `bash` shell as the `Termux app` user with priority set to termux bin and library paths with the default configuration.  

`tudo su`  


- Drop to an interactive `python` shell as the `Termux app` user with priority set to termux bin and library paths.  

`tudo --shell=python --work-dir="~/" su`  


- Drop to an interactive `bash` shell as the `Termux app` user with priority set to termux bin and library paths with `/.tudo` directory as `tudo shell` home.

`tudo --shell-home="/.tudo" su`  


- Drop to an interactive `bash` shell as the `Termux app` user with priority set to termux bin and library paths with `/.tudo` as the shell home and termux home as the working directory. All paths currently in `$PATH` and `$LD_LIBRARY_PATH` are also exported.  

`tudo -LP --shell-home="/.tudo" --work-dir='~/' su`  


- Drop to an interactive `bash` shell as the `Termux app` user with priority set to termux bin and library paths, do not store history, export some additional paths in `$PATH` variable, pass additional options to the bash interactive shell starting including a different rc/init file and run some commands before running the bash shell like exporting some variables and running a script. The value of the [`--shell-options`](#--shell-options) option is surrounded with double quotes and the [`--init-file`](#--init-file) option value passed in it has double quotes escaped to prevent whitespace splitting when its passed to `bash`. The [`--shell-pre-commands`](#--shell-pre-commands) option is instead surrounded with single quotes as an example and so doesn't need double quotes escaped but will require single quotes in commands to be escaped.

`tudo --no-hist --export-paths="/path/to/dir1:/path/to/dir2" --shell-options="--noprofile --init-file \"path/to/file\"" --shell-pre-commands='export VARIABLE_1="VARIABLE_VALUE_1"; export VARIABLE_2="VARIABLE_VALUE_2"; /path/to/script;' su`  

## &nbsp;

&nbsp;



### `asu`

- Drop to an interactive `bash` shell as the `Termux app` user with priority set to android bin and library paths with the default configuration.  

`tudo asu`  

## &nbsp;

&nbsp;



### `path`

- Run `top` command to show top `10` processes of any user.  

`tudo top -m 10 -n 1`  


- Run `ps` command to processes of all users.  

`tudo ps -ef`  


- Run android `getprop` command to get device `sdk` version.  

`tudo getprop "ro.build.version.sdk"`  

## &nbsp;

&nbsp;



### `script`


#### `bash`

- Pass a `bash` script text surrounded with single quotes that prints the first `2` args to `stdout`. There is normally no need to pass `--shell=bash` since `bash` shell would be the default shell.  

```
tudo -s 'echo "Hi, $1 $2."' "bash" "shell"
```



- Pass a `bash` script text surrounded with single quotes that prints the first `2` args to `stdout` and start an interactive `bash` shell.  

```
tudo -si 'echo "Hi, $1 $2."' "bash" "shell"
```



- Pass a `bash` script text surrounded with single quotes that prints the first `2` args to `stdout` and start an interactive `bash` shell. The script is forcefully stored in a temp file named `tudo_test` in a temp directory `$TMPDIR/.tudo.temp.XXXXXX`, which is also not deleted after `tudo` exits. The title of the terminal session is also set to `tudo_test`.  

```
tudo -sif --keep-temp --script-name="tudo_test" --title="tudo_test" 'echo "Hi, $1 $2."' "bash" "shell"
```



- Pass a path to `bash` script file to the `bash` shell instead of script text, with `2` args and start an interactive `bash` shell.  

```
tudo -siF '~/.termux/tasker/termux_tasker_basic_bash_test' "bash" "shell"
```



- Pass a `bash` script text surrounded with single quotes that prints the first `2` args to `stdout` and run some commands before running the script like exporting some variables. The [`--shell-pre-commands`](#--shell-pre-commands) option is surrounded with single quotes and so doesn't need double quotes escaped but will require single quotes in commands to be escaped.

```
tudo -s --shell-pre-commands='
export VARIABLE_1="VARIABLE_VALUE_1"
export VARIABLE_2="VARIABLE_VALUE_2"
' '
echo "Hi, $1 $2."
echo "VARIABLE_1=\`$VARIABLE_1\`"
echo "VARIABLE_2=\`$VARIABLE_2\`"
' "bash" "shell"
```



- Pass a `bash` script text surrounded with single quotes that prints the first `2` args to `stdout`and start an interactive `python` shell and run some commands before running the script, after running the script but before going to launcher activity, and after going to launcher activity but before starting the interactive `python` shell.  

```
tudo -sil --post-shell="python" --shell-pre-commands='echo "Running script"' --shell-post-commands='echo "Script complete\nGoing to launcher"' --shell-pre-commands='echo "Starting interactive python shell"' 'echo "Hi, $1 $2."' "bash" "shell"
```



- Pass a `bash` script text with process substitution that reads a name from `stdin` and prints it to `stdout`.  

```
tudo -s --shell=bash <(cat <<'TUDO_EOF'
echo 'What is your name?'
read name
echo "Hi, $name."
TUDO_EOF
)
```



- Pass a `bash` script text surrounded with single quotes that reads a name from `stdin` and prints it to `stdout`.  

```
tudo -s --shell=bash '
echo "What is your name?"
read name
echo "Hi, $name."
'
```



- Pass a `bash` script text surrounded with single quotes that reads a name from `stdin` and prints it to `stdout`, where the script itself also contains single quotes.  

```
tudo -s --shell=bash '
echo '\''What is your name?'\''
read name
echo "Hi, $name."
'
```



- Pass a `bash` script text with process substitution that prints the first `2` args to `stdout` and start an interactive shell if only `2` args are received, otherwise exits early with an error without starting the interactive shell afterwards. Additional arguments that will be passed to the `core_script` are passed to `tudo` after the process substitution ends.  

```
tudo -sie --shell=bash <(cat <<'TUDO_EOF'
#if argument count is not 2
if [ $# -ne 2 ]; then
    echo "Invalid argument count '$#' to 'termux_tasker_basic_bash_test'" 1>&2
    echo "$*" 1>&2
    exit 1
fi

echo "\$1=\`$1\`"
echo "\$2=\`$2\`"

exit 0
TUDO_EOF
) "hello," "termux!"
```



- Pass a `bash` script text surrounded with single quotes that redirects `stderr` of the `core_script` to `stdout` so that both `stdout` and `stderr` can be received in a synchronized way as `stdout`, like in `%stdout` variable for `Termux:Tasker` plugin app for easier processing of result of commands.  

```
tudo -so 'echo stdout; echo stderr 1>&2'
```



- Pass a `bash` script to start the `sshd` server and automatically go to launcher activity. The script will also automatically start an interactive `bash` shell after starting the `sshd` server so that `termux` service and `sshd` service keep running in the background because of the permanent `termux` notification, You can run the script from `Termux:Tasker` plugin app on device boot, make sure `Execute in a terminal session` toggle is enabled. It can also be run with the `RUN_COMMAND` intent. *(This is how this whole tudo and sudo shit started)*  

```
tudo -seli -v --hold --hold-if-fail --title='sshd' '
echo -e "Starting sshd server...\n"
sshd
return_value=$?
if [ $return_value -ne 0 ]; then
    echo -e "The sshd server failed to start" 1>&2
    exit $return_value
else
    echo -e "The sshd server started successfully.\nDo not close this session.\nOtherwise commands over ssh will not work or will get killed while running."
    sleep 3
fi
'
```

## &nbsp;

&nbsp;



#### `zsh`

- Pass a `zsh` script text with process substitution that prints the first `2` args to `stdout`.  

```
tudo -s --shell=zsh <(cat <<'TUDO_EOF'
echo "Hi, $1 $2."
TUDO_EOF
) "zsh" "shell"
```



- Pass a `zsh` script text with process substitution that reads a name from `stdin` and prints it to `stdout`.  

```
tudo -s --shell=zsh <(cat <<'TUDO_EOF'
echo "What is your name?"
read name
echo "Hi, $name."
TUDO_EOF
)
```

## &nbsp;

&nbsp;



#### `fish`

- Pass a `fish` script text with process substitution that prints the first `2` args to `stdout`.  

```
tudo -s --shell=fish <(cat <<'TUDO_EOF'
echo "Hi, $argv[1] $argv[2]."
TUDO_EOF
) "fish" "shell"
```



- Pass a `fish` script text with process substitution that reads a name from `stdin` and prints it to `stdout`.  

```
tudo -s --shell=fish <(cat <<'TUDO_EOF'
echo "What is your name?"
read -p "" name
echo "Hi, $name."
TUDO_EOF
)
```

## &nbsp;

&nbsp;



#### `python`

Currently, `python` refers to `python3` and `python2` refers to `python2` in termux. Check [Termux Python Wiki](https://wiki.termux.com/wiki/Python) for more information.

- Pass a `python` script text with process substitution that prints the first `2` args to `stdout`.  

```
tudo -s --shell=python <(cat <<'TUDO_EOF'
import sys
print("Hi, %s %s." % (sys.argv[1], sys.argv[2]))
TUDO_EOF
) "python" "shell"
```



- Pass a `python` script text with process substitution that reads a name from `stdin` and prints it to `stdout`.  

```
tudo -s --shell=python <(cat <<'TUDO_EOF'
name = input("What is your name?\n")
print("Hi, %s." % name)
TUDO_EOF
)
```

&nbsp;


*The following "tests" are in solidarity with the `youtube-dl` devs, EFF and the current Github response of the "incident".*

The `youtube-dl` file is actually not a single python script text file but is a [binary file](https://github.com/ytdl-org/youtube-dl/blob/9fe50837c3e8f6c40b7bed8bf7105a868a7a678f/Makefile#L70) containing multiple python files.

- Read `python` script text from a file using `cat` and pass it with process substitution. Passing the data of the `youtube-dl` file to `tudo` script using process substitution will engage automatic `base64` encoding of the data and creation of temp script file. The `youtube-dl` generates its help output based on the named of the its own file, hence [`--script-name`](#--script-name) is passed, otherwise help with contain `tudo_script__core_script` entries instead. The current size of the `youtube-dl` binary is over `1MB` and so its data cannot be passed as an argument directly (after `base64` encoding) since [Arguments Data Limits](#arguments-and-result-data-limits) will cross.  

```
tudo -s --shell=python --script-name="youtube-dl" <(cat "$PREFIX/bin/youtube-dl") --help
```


- Pass a path to `python` script file to the `python` shell instead of script text, with an arg.  

```
tudo -sF --shell=python '$PREFIX/bin/youtube-dl' --help
```


- Read `python` script text from a file using `cat` in a subshell and pass it as an argument. The script size must not cross [Arguments Data Limits](#arguments-and-result-data-limits). If the script contains binary or non `UTF-8` data, then pipe the output of `cat` to `base64` and also pass the [`--script-decode`](#--script-decode) option.  

```
tudo -s --shell=python "$(cat "$PREFIX/bin/bandcamp-dl")" --help
```

```
tudo -s --script-decode --shell=python "$(cat "$PREFIX/bin/bandcamp-dl" | base64)" --help
```

## &nbsp;

&nbsp;



#### `ruby`

- Pass a `ruby` script text with process substitution that prints the first `2` args to `stdout`.  

```
tudo -s --shell=ruby <(cat <<'TUDO_EOF'
puts "Hi, " + ARGV[0] + " " + ARGV[1] + "."
TUDO_EOF
) "ruby" "shell"
```



- Pass a `ruby` script text with process substitution that reads a name from `stdin` and prints it to `stdout`.  

```
tudo -s --shell=ruby <(cat <<'TUDO_EOF'
puts "What is your name?"
name = STDIN.gets
name = '' if name.nil?
puts "Hi, " + name.chomp.to_s + "."
TUDO_EOF
)
```

## &nbsp;

&nbsp;



#### `node`

- Pass a `node` script text with process substitution that prints the first `2` args to `stdout`.  

```
tudo -s --shell=node <(cat <<'TUDO_EOF'
console.log(`Hi, ${process.argv[2]} ${process.argv[3]}.`)
TUDO_EOF
) "node" "shell"
```



- Pass a `node` script text with process substitution that reads a name from `stdin` and prints it to `stdout`.  

```
tudo -s --shell=node <(cat <<'TUDO_EOF'
const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
})

readline.question(`What is your name?\n`, (name) => {
    console.log(`Hi, ${name}.`)
    readline.close()
})
TUDO_EOF
)
```

## &nbsp;

&nbsp;



#### `perl`

- Pass a `perl` script text with process substitution that prints the first `2` args to `stdout`.  

```
tudo -s --shell=perl <(cat <<'TUDO_EOF'
print "Hi, ", $ARGV[0], " ", $ARGV[1], ".\n";
TUDO_EOF
) "perl" "shell"
```



- Pass a `perl` script text with process substitution that reads a name from `stdin` and prints it to `stdout`.  

```
tudo -s --shell=perl <(cat <<'TUDO_EOF'
print "What is your name?\n";
$name = <STDIN>;
chomp($name);
print "Hi, ", $name, ".\n";
TUDO_EOF
)
```

## &nbsp;

&nbsp;



#### `lua5.2`

- Pass a `lua5.2` script text with process substitution that prints the first `2` args to `stdout`.  

```
tudo -s --shell=lua5.2 <(cat <<'TUDO_EOF'
io.write('Hi, ', arg[1], ' ', arg[2], '.\n')
TUDO_EOF
) "lua5.2" "shell"
```



- Pass a `lua5.2` script text with process substitution that reads a name from `stdin` and prints it to `stdout`.  

```
tudo -s --shell=lua5.2 <(cat <<'TUDO_EOF'
io.write('What is your name?\n')
local name = io.read()
io.write('Hi, ', name, '.\n')
TUDO_EOF
)
```

## &nbsp;

&nbsp;



#### `lua5.3`

- Pass a `lua5.3` script text with process substitution that prints the first `2` args to `stdout`.  

```
tudo -s --shell=lua5.3 <(cat <<'TUDO_EOF'
io.write('Hi, ', arg[1], ' ', arg[2], '.\n')
TUDO_EOF
) "lua5.3" "shell"
```



- Pass a `lua5.3` script text with process substitution that reads a name from `stdin` and prints it to `stdout`.  

```
tudo -s --shell=lua5.3 <(cat <<'TUDO_EOF'
io.write('What is your name?\n')
local name = io.read()
io.write('Hi, ', name, '.\n')
TUDO_EOF
)
```

## &nbsp;

&nbsp;



#### `lua5.4`

- Pass a `lua5.4` script text with process substitution that prints the first `2` args to `stdout`.  

```
tudo -s --shell=lua5.4 <(cat <<'TUDO_EOF'
io.write('Hi, ', arg[1], ' ', arg[2], '.\n')
TUDO_EOF
) "lua5.4" "shell"
```



- Pass a `lua5.4` script text with process substitution that reads a name from `stdin` and prints it to `stdout`.  

```
tudo -s --shell=lua5.4 <(cat <<'TUDO_EOF'
io.write('What is your name?\n')
local name = io.read()
io.write('Hi, ', name, '.\n')
TUDO_EOF
)
```

## &nbsp;

&nbsp;



#### `php`

- Pass a `php` script text with process substitution that prints the first `2` args to `stdout`.  

```
tudo -s --shell=php <(cat <<'TUDO_EOF'
<?php
echo "Hi, " . $argv[1] . " " . $argv[2] . ".\n";
TUDO_EOF
) "php" "shell"
```



- Pass a `php` script text with process substitution that reads a name from `stdin` and prints it to `stdout`.  

```
tudo -s --shell=php <(cat <<'TUDO_EOF'
<?php
echo "What is your name?\n";
$name = readline();
echo "Hi, " . $name . ".\n";
TUDO_EOF
)
```
---

&nbsp;





## Templates

### Tasker

- `Tasks`  
    - `XML`  
        Download the [Termux Tasker Plugin Tudo Templates Task XML](https://github.com/agnostic-apollo/tudo/tree/master/templates/plugin_hosts/tasker/Termux_Tasker_Plugin_Tudo_Templates.tsk.xml) and [Termux RUN_COMMAND Intent Tudo Templates Task XML](templates/plugin_hosts/tasker/Termux_RUN_COMMAND_Intent_Tudo_Templates.tsk.xml) files to the android download directory. To download, right-click or hold the `Raw` button at the top after opening a file link and select `Download/Save link` or use `curl` from a termux shell. Then import the downloaded task files into Tasker by long pressing the `Task` tab button in Tasker home and selecting `Import Task`.  

        `curl -L 'https://github.com/agnostic-apollo/tudo/raw/master/templates/plugin_hosts/tasker/Termux_Tasker_Plugin_Tudo_Templates.tsk.xml' -o "/sdcard/Download/Termux_Tasker_Plugin_Tudo_Templates.tsk.xml"`  

        `curl -L 'https://github.com/agnostic-apollo/tudo/raw/master/templates/plugin_hosts/tasker/Termux_RUN_COMMAND_Intent_Tudo_Templates.tsk.xml' -o "/sdcard/Download/Termux_RUN_COMMAND_Intent_Tudo_Templates.tsk.xml"`  

    - `Taskernet`  
        Import `Termux Tasker Plugin Tudo Templates Task` from `Taskernet` from [here](https://taskernet.com/shares/?user=AS35m8mXdvaT1Vj8TwkSaCaoMUv220IIGtHe3pG4MymrCUhpgzrat6njEOnDVVulhAIHLi6BPUt1&id=Task%3ATermux+Tasker+Plugin+Tudo+Templates).  
        Import `Termux RUN_COMMAND Intent Tudo Templates Task` from `Taskernet` from [here](https://taskernet.com/shares/?user=AS35m8mXdvaT1Vj8TwkSaCaoMUv220IIGtHe3pG4MymrCUhpgzrat6njEOnDVVulhAIHLi6BPUt1&id=Task%3ATermux+RUN_COMMAND+Intent+Tudo+Templates).  

    Check [Termux Tasker Plugin Tudo Templates Task Info](https://github.com/agnostic-apollo/tudo/tree/master/templates/plugin_hosts/tasker/Termux_Tasker_Plugin_Tudo_Templates.tsk.md) and [Termux RUN_COMMAND Intent Tudo Templates Task Info](https://github.com/agnostic-apollo/tudo/tree/master/templates/plugin_hosts/tasker/Termux_RUN_COMMAND_Intent_Tudo_Templates.tsk.md) files for more info on the tasks.  


Termux needs to be granted `Storage` permission to allow it to access `/sdcard/Download` directory, otherwise you will get permission denied errors while running commands.

---

&nbsp;





## Passing Arguments

The `core_script` or any other arguments passed for all the command types must be preserved in their original form and must be passed as is to `tudo` without any variable expansion or history expansion, etc.

This can be done in two ways, either using single quotes to surround the `core_script` and arguments or passing them with process substitution with a literal `cat` `heredoc`.

&nbsp;

If you are using [Termux:Tasker] plugin to run `tudo` commands, you would need to use single quotes to pass arguments, since it doesn't support process substitution. You would need to install [Termux:Tasker] version `>= 0.5` since argument parsing is broken in older versions. Check the [Passing Arguments Surrounded With Single Quotes](#passing-arguments-surrounded-with-single-quotes) section for more details. Check the `Template 2` and `Template 3` of the [Termux Tasker Plugin Tudo Templates Task](#templates) task for templates on how to use single quotes to pass arguments with Tasker. Basically, just set your script text to the `%core_script` variable with the `Variable Set` action and add any additional command options or arguments to the `%arguments` variable.

&nbsp;

If you are using a foreground terminal session or scripts to run `tudo` commands, you can use single quotes to pass arguments or use process substitution. If you are using a foreground terminal session, then you must disable the `bash` command completion and history expansion for the current terminal session before running `tudo` command to pass multi-line arguments by running `bind 'set disable-completion on'; set +H`. Check the [Passing Arguments Using Process Substitution](#passing-arguments-using-process-substitution) section for more details. Check the [Examples](#examples) section for templates on how to use process substitution to pass arguments.

&nbsp;

If you are using [RUN_COMMAND Intent] to run `tudo` commands with Tasker using the `TermuxCommand()` function in `Tasker Function` action, you don't need to surround the `core_script` or arguments with single quotes, since arguments are split on a simple comma `,` instead. If your arguments themselves contain simple commas `,` (`U+002C`, `&comma;`, `&#44;`, `comma`), then you must replace them with the comma alternate character `‚` (`#U+201A`, `&sbquo;`, `&#8218;`, `single low-9 quotation mark`) for each argument separately before passing them to the intent action and would also need to pass the [`-r`](#-r) command option to `tudo`. Check the [Passing Arguments Using RUN_COMMAND Intent](#passing-arguments-using-run_command-intent) section for more details. Check the `Template 2` of the [Termux RUN_COMMAND Intent Tudo Templates Task](#templates) task for a template on how to replace commas in each argument separately with Tasker.

&nbsp;

If you are using [RUN_COMMAND Intent] to run `tudo` commands with Tasker or other apps using the `am` command, like using the `Run Shell` action in Tasker, you need to surround all your arguments, like the `core_script` and all other arguments with single quotes when passing them to the `com.termux.RUN_COMMAND_ARGUMENTS` string array extra after you have escaped all the single quotes in the final value, since otherwise it may result in incorrect quoting if the arguments themselves contain single quotes. However, due to the string array extra, the arguments are still split on a simple comma `,` so if your arguments themselves contain simple commas `,` (`U+002C`, `&comma;`, `&#44;`, `comma`), then you would also have to replace them with the comma alternate character `‚` (`#U+201A`, `&sbquo;`, `&#8218;`, `single low-9 quotation mark`) for each argument separately before passing them as the argument to the extra and would also need to pass the [`-r`](#-r) command option to `tudo`. Check the [Passing Arguments Using RUN_COMMAND Intent](#passing-arguments-using-run_command-intent) section for more details. Check the `Template 3` of the [Termux RUN_COMMAND Intent Tudo Templates Task](#templates) task for a template on how to replace commas in each argument separately and also escape single quotes in all the arguments with Tasker.

&nbsp;

Note that for [RUN_COMMAND Intent], any arguments passed to any command options or the main arguments to `tudo` should also **not** be surrounded with single or double quotes to prevent whitespace splitting in the intent action, like done for usage with `Termux:Tasker` plugin app since splitting will occur on simple comma characters instead. Check the `Template 4` of the [Termux RUN_COMMAND Intent Tudo Templates Task](#templates) task for a template for this.

&nbsp;



### Passing Arguments Surrounded With Single Quotes

Any argument surrounded with single quotes is considered a literal string and variable expansion is not done. However, if an argument itself contains single quotes, then they will need to be escaped properly. You can escape them by replacing all single quotes `'` in an argument value with `'\''` **before** passing the argument surrounded with single quotes. So an argument surrounded with single quotes that would have been passed like `'some arg with single quote ' in it'` will be passed as `'some arg with single quote '\'' in it'`. This is basically 3 parts `'some arg with single quote '`, `\'` and `' in it'` but when processed, it will be considered as one single argument with the value `some arg with single quote ' in it` that is passed to `tudo`.

For `Tasker`, you can use the `Variable Search Replace` action on an `%argument` variable to escape the single quotes. Set the `Search` field to one single quote `'`, and enable `Replace Matches` toggle, and set `Replace With` field to one single quote, followed by two backslashes, followed by two single quotes `'\\''`. The double backslash is to escape the backslash character itself.

Escaping single quotes while running commands in a foreground terminal session will be much harder if there are many single quotes, same would apply for double quote surrounded strings, so use process substitution instead, check below.

The format is the following

```
tudo -s '
<core_script>
' '[some arg1]' '[some arg2]'
```

## &nbsp;

&nbsp;



### Passing Arguments Using Process Substitution

[Process Substitution] can be used to pass the `core_script` and `core_script_args` for the `script` command type and to pass the `command_args` for the `path` command type when running `tudo` from a foreground terminal session or from a script.

The following is the format for passing `core_script` text.

```
tudo -s <(cat <<'TUDO_EOF'
<core_script>
TUDO_EOF
)
```

The following is the process substitution part

```
<(

)
```

Inside it there is a `cat` [Here Document]. The script text should start after a newline after the `'TUDO_EOF'` part. You can type anything as script text other than `TUDO_EOF` which when read, ends the script. The ending `TUDO_EOF` should be alone on a separate line. The starting `'TUDO_EOF'` is surrounded with single quotes so that script is considered a literal string and variable expansion, etc doesn't happen.

```
cat <<'TUDO_EOF'

TUDO_EOF
```

Basically any text you type inside the `cat` heredoc will be passed to the process substitution which will create a temporary file descriptor for it in `/proc/self/fd/<n>` and pass the path to `tudo` script so that it can read the argument text from it.

You can also read text from an existing script file using `cat` and pass that to `tudo` like the following

```
tudo -s <(cat "~/some-script")
```

## &nbsp;

&nbsp;



### Passing Arguments Using RUN_COMMAND Intent

To use [RUN_COMMAND Intent] that has arguments working properly, you need to install Termux version `>= 0.100` and Tasker version `>= 5.9.4.beta`. However, leading and trailing whitespaces from arguments will be removed for Tasker version `< 5.11.1.beta` if you are using `TermuxCommand()` function, so its advisable to use a higher version or use `am` command instead.

&nbsp;

If you are using the `am` command, the format is `am startservice --user 0 -n com.termux/com.termux.app.RunCommandService -a com.termux.RUN_COMMAND --es com.termux.RUN_COMMAND_PATH '<path>' --esa com.termux.RUN_COMMAND_ARGUMENTS '<one_or_more_args_seperated_with_commas>' --ez com.termux.RUN_COMMAND_BACKGROUND 'false'`

&nbsp;

If you are using the `TermuxCommand()` function, the format is `TermuxCommand(path,<one_or_more_args_seperated_with_commas>,workdir,background)`. The args can be of any count, each separated with a simple comma `,`. The only condition is that in the list the first must be `path` and the last two must be `workdir` and `background` respectively.

&nbsp;

For both the `--esa com.termux.RUN_COMMAND_ARGUMENTS` string array extra and the `TermuxCommand()` function, if you want to pass an argument that itself contains a simple comma `,` (`U+002C`, `&comma;`, `&#44;`, `comma`), it must be escaped with a backslash `\,` so that the  argument isn't split into multiple arguments. The only problem is that, the arguments received by the script being executed will contain `\,` instead of `,` since the reversal isn't done as described in the [am command source](https://android.googlesource.com/platform/frameworks/base/+/21bdaf1/cmds/am/src/com/android/commands/am/Am.java#572) while converting to a string array. Tasker uses the same method. There is also no way for the `am` command or the script to know whether `\,` was done to prevent arguments splitting or `\,` was a literal string naturally part of the argument.

```
// Split on commas unless they are preceeded by an escape.
// The escape character must be escaped for the string and
// again for the regex, thus four escape characters become one.
String[] strings = value.split("(?<!\\\\),");
intent.putExtra(key, strings);
```

&nbsp;

`tudo` uses an alternative method to handle such conditions. If an argument contains a simple comma `,`, then instead of escaping them with a backslash `\,`, replace all simple commas with the comma alternate character `‚` (`#U+201A`, `&sbquo;`, `&#8218;`, `single low-9 quotation mark`). This way argument splitting will not be done. You can pass the [`-r`](#-r) option to `tudo` which will then parse arguments as per `RUN_COMMAND` intent rules to replace all the comma alternate characters back to simple commas. It would be unlikely for the `core_script` or the arguments to naturally contain the comma alternate characters for this to be a problem. Even if they do, they might not be significant for any script logic. If they are, then you can set a different character that should be replaced, with the [`--comma-alternative`](#--comma-alternative) option. The [`-r`](#-r) and [`--comma-alternative`](#--comma-alternative) options should ideally be the first options passed so that `tudo` replaces the alternative comma characters from all arguments passed after the options.

For `Tasker` use the `Variable Search Replace` action on an `%argument` variable to replace the simple comma characters. Set the `Search` field to one simple comma `,`, and enable `Replace Matches` toggle, and set `Replace With` field to `%comma_alternative` where the `%comma_alternative` variable must contain the comma alternate character `‚`.

---

&nbsp;





## Issues

`-`

---

&nbsp;





## Worthy Of Note

- [RC File Variables](#rc-file-variables)
- [Arguments and Result Data Limits](#arguments-and-result-data-limits)
- [`$PATH` and `$LD_LIBRARY_PATH` Priorities](#path-and-ld_library_path-priorities)
- [`tpath` and `apath` functions](#tpath-and-apath-functions)
- [`export` and `unset` functions](#export-and-unset-functions)
- [`su` search-paths](#su-search-paths)

&nbsp;



### RC File Variables

If you don't know what `$PATH`, `$LD_LIBRARY_PATH` and `$PS1` variables or `rc` files are or don't care to find out, then just run the commands below so that `tudo` works properly, otherwise read the details below. Ignore `No such file or directory` errors when running the commands.

```
sed -i'' -E 's/^(PS1=.*)$/\(\[ -z "\$PS1" \] \|\| \[\[ "\$PS1" == '\''\\s-\\v\\\$ '\'' \]\]\) \&\& \1/' "${TERMUX__PREFIX:-$PREFIX}/etc/bash.bashrc"
sed -i'' -E 's/^(PS1=.*)$/\(\[ -z "\$PS1" \] \|\| \[\[ "\$PS1" == '\''%m%# '\'' \]\]\) \&\& \1/' "${TERMUX__PREFIX:-$PREFIX}/etc/zshrc"
```

&nbsp;


`rc` files, short for `run commands`, are shell specific files that are run or sourced whenever an interactive shell is started to define variables and functions etc.

Make sure in your `rc` files like `~/.bashrc` file for `bash` (where `~/` is the `tudo shell` home), the `$PATH`, `$LD_LIBRARY_PATH` and `$PS1` variables and any other variables exported by `tudo` are not overridden, **otherwise the `tudo` commands will not work properly**, since `tudo` exports its own custom variable values which will get overridden when `rc` files are sourced by any new shell started. You can run commands like `tudo -v --dry-run --shell=bash su` to see what variables are normally exported for a given shell by `tudo`.

&nbsp;


#### `$PATH` and `$LD_LIBRARY_PATH` RC File Variables

Check the [`$PATH` and `$LD_LIBRARY_PATH` Priorities](#path-and-ld_library_path-priorities) section for more info on what these variables are.

For the `$PATH` and `$LD_LIBRARY_PATH` variables, either remove their variable set lines completely or if necessary only append any required paths to the existing variable values like `export PATH="$PATH:/dir1:/dir2"` and `export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/dir1:/dir2"` instead of overriding them with `export PATH="/dir1:/dir2"` and `export LD_LIBRARY_PATH="/dir1:/dir2"` in your `rc` files.

&nbsp;

#### `$PS1` RC File Variables

The `$PS1` variable, short for [Prompt String 1], defines the characters you see at the start of the "line" when typing commands in shells running interactively like `bash` or `zsh`. For `termux` `bash` shell, this defaults to `$ `. For `termux` `zsh` shell, this defaults to `% `.

If you want to allow `tudo` to set its own default `$PS1` value `Ⲧ ` or the one set with the `$TUDO__SHELL_PS1` or `$TUDO__POST_SHELL_PS1` variables in the `tudo.config` file, then **make sure the `$PS1` value is not overridden by the shell `rc` files, otherwise you will not be able to easily tell the difference between whether you are running a shell via `tudo` or normally as the `Termux app` user when you run commands like `tudo su`.** You can however check the value of `$SHLVL` to see the nested shell level, run `printenv | grep SHLVL`.

1. The `rc` files in `$PREFIX/etc/` are sourced first whenever shells are started by `tudo`. The `$PS1` value is set and exported by `tudo` before new shells are started, however, the value will get replaced if its overridden by the `rc` files when they are sourced during startup of the new shell.  

    - `bash` shell currently uses the `$PREFIX/etc/bash.bashrc` file, in which it sets the default value of `$PS1` to `\$ ` or `\[\e[0;32m\]\w\[\e[0m\] \[\e[0;97m\]\$\[\e[0m\] ` in recent versions. You need to replace the line `PS1='\$ '` or `PS1=<default>` with the conditional `([[ -z "$PS1" ]] || [[ "$PS1" == '\s-\v\$ ' ]]) && PS1=<default>` so that `$PS1` is only set if its not already set or is set to the default value internally used by `bash`. You can run the command `sed -i'' -E 's/^(PS1=.*)$/\(\[ -z "\$PS1" \] \|\| \[\[ "\$PS1" == '\''\\s-\\v\\\$ '\'' \]\]\) \&\& \1/' "${TERMUX__PREFIX:-$PREFIX}/etc/bash.bashrc"` to automatically do it or you can do it manually by running `nano "${TERMUX__PREFIX:-$PREFIX}/etc/bash.bashrc"`.  

    - `zsh` shell currently uses the `$PREFIX/etc/zshrc` file, in which it sets the default value of `$PS1` to `%# `. You need to replace the line `PS1='%# '` or `PS1=<default>` with the conditional `([[ -z "$PS1" ]] || [[ "$PS1" == '%m%# ' ]]) && PS1=<default>` so that `$PS1` is only set if its not already set or is set to the default value internally used by `zsh`. You can run the command `sed -i'' -E 's/^(PS1=.*)$/\(\[ -z "\$PS1" \] \|\| \[\[ "\$PS1" == '\''%m%# '\'' \]\]\) \&\& \1/' "${TERMUX__PREFIX:-$PREFIX}/etc/zshrc"` to automatically do it or you can do it manually by running `nano "${TERMUX__PREFIX:-$PREFIX}/etc/zshrc"`.  

2. The `rc` files in `~/` (default `tudo shell` home) are also sourced afterwards whenever shells are started by `tudo`. They must also not override the `$PS1` value. However, if you want to set a custom value in them for usage outside `tudo`, then you can add conditionals to override `$PS1` only if its not already set or is set to the default `termux` value set by `$PREFIX/etc/*` `rc` files.  

    - `bash` shell default `rc` file set by `tudo` is `~/.bashrc`. You can for example set `$PS1` to `£ ` by adding the line `([[ -z "$PS1" ]] || [[ "$PS1" == '\$ ' ]]) && PS1='£ '` to it, where `'\$ '` is the default value for `PS1` in `$PREFIX/etc/bash.bashrc` file.  

    - `zsh` shell default `rc` file set by `tudo` is `~/.zshrc`. You can for example set `$PS1` to `£ ` by adding the line `([[ -z "$PS1" ]] || [[ "$PS1" == '%# ' ]]) && PS1='£ '` to it, where `'%# '` is the default value for `PS1` in `$PREFIX/etc/zshrc` file.  

This will ensure that the exported `$PS1` variables will not be overridden by `rc` files for `bash` and `zsh`. For other shells that may use the `$PS1` variable, you can use similar conditionals in their `rc` files.

## &nbsp;

&nbsp;



### Arguments and Result Data Limits

There are limits on the arguments size you can pass to commands or the full command string length that can be run, which is likely equal to `131072` bytes or `128KB` for an android device defined by `ARG_MAX` but after subtracting shell environment size, etc, it will roughly be around `120-125KB` but limits may vary for different android versions and kernels. You can check the limits for a given termux session by running `true | xargs --show-limits`. If you exceed the limit, you will get exceptions like `Argument list too long`. You can manually cross the limit by running something like `$PREFIX/bin/echo "$(head -c 131072 < /dev/zero | tr '\0' 'a')" | tr -d 'a'`, use full path of `echo`, otherwise the `echo` shell built-in will be called to which the limit does not apply since `exec` is not done.

Moreover, exchanging data between `Tasker` and `Termux:Tasker` is done using [Intents](https://developer.android.com/guide/components/activities/parcelables-and-bundles), like sending the command and receiving result of commands in `%stdout` and `%stderr`. However, android has limits on the size of *actual* data that can be sent through intents, it is roughly `500KB` on android `7` but may be different for different android versions.

Basically, make sure any data/arguments you pass to `tudo` script directly on the shell or through scripts or using the `Termux:Tasker` plugin app or [RUN_COMMAND Intent] intent is less than `120KB` (or whatever you found) and any expected result sent back if using the `Termux:Tasker` plugin app is less than `500KB`, but best keep it as low as possible for greater portability. If you want to exchange an even larger data between tasker and termux, use physical files instead.

The argument data limits also apply for the [RUN_COMMAND Intent] intent.

## &nbsp;

&nbsp;



### `$PATH` and `$LD_LIBRARY_PATH` Priorities

**Check [Termux Execution Environment](https://github.com/termux/termux-packages/wiki/Termux-execution-environment) docs before continuing for info on how execution and dynamic linking happens in Termux, including issues/errors related to them and what path related environment variables are exported by Android and Termux by default.**

#### Path Environment Variables Exported By `tudo`

The `tudo` script exports variables depending on the flags passed. If flags are not passed, then the [`su`](#su) and [`script`](#script) command types export variables as per [`-t`](#-t) flag, the [`asu`](#asu) command type export variables as per [`-a`](#-a) flag and the [`path`](#path) command types export variables as per [`-t`](#-t) flag if executable `canonical` path is under `$TERMUX__ROOTFS` directory, otherwise as per [`-a`](#-a) flag.

The `$PATH` variable value will depend on the flag passed and will vary depending on Android version. If custom paths are passed with [`--export-paths`](#--export-paths) or `$TUDO__ADDITIONAL_PATHS_TO_EXPORT`, they will be still set or appended to `$PATH`.

The `$LD_LIBRARY_PATH` variable will not be set for Android `>= 7` for any flags, since `DT_RUNPATH` is used by termux. It will contain `$TERMUX__PREFIX/lib` for Android `< 7`, but only for [`-a`](#-a), [`-t`](#-t), [`-T`](#-t-1) and [`-TT`](#-tt) flags, i.e for priority flags for which termux `bin` paths exist in `$PATH` as `DT_RUNPATH` is not used by termux for Android `< 7` packages. However, if custom paths are passed with [`--export-ld-lib-paths`](#--export-ld-lib-paths) or `$TUDO__ADDITIONAL_LD_LIBRARY_PATHS_TO_EXPORT`, they will still be set or appended to `$LD_LIBRARY_PATH`.

The `$LD_PRELOAD` variable will contain `$TERMUX__PREFIX/lib/libtermux-exec.so` only for [`-t`](#-t), [`-T`](#-t-1), [`-TT`](#-tt) flags.

So as per [Path Environment Variables Exported By Android](https://github.com/termux/termux-packages/wiki/Termux-execution-environment#path-environment-variables-exported-by-android) and [Path Environment Variables Exported By Termux](https://github.com/termux/termux-packages/wiki/Termux-execution-environment#path-environment-variables-exported-by-termux), for a `64-bit` Android `>= 11`, the `tudo` script would export the following variables depending on the flags passed.

- [`-a`](#-a)  
    - `$PATH`: All android bin paths followed all termux bin paths: `/product/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin:/system_ext/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets`  
    - `$LD_LIBRARY_PATH`:  
        - Android `>= 7`: Not set by default.  
        - Android `< 7`: `/data/data/com.termux/files/usr/lib`  
    - `$LD_PRELOAD`: Not set by default.  
- [`-A`](#-a-1)  
    - `$PATH`: Only android system bin path: `/system/bin`  
    - `$LD_LIBRARY_PATH`: Not set by default.  
    - `$LD_PRELOAD`: Not set by default.  
- [`-AA`](#-aa)  
    - `$PATH`: All android bin paths: `/product/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin:/system_ext/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin`  
    - `$LD_LIBRARY_PATH`: Not set by default.  
    - `$LD_PRELOAD`: Not set by default.  
- [`-t`](#-t)  
    - `$PATH`: All termux bin paths followed all android bin paths: `/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets:/product/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin:/system_ext/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin`  
    - `$LD_LIBRARY_PATH`:  
        - Android `>= 7`: Not set by default.  
        - Android `< 7`: `/data/data/com.termux/files/usr/lib`  
    - `$LD_PRELOAD`: `/data/data/com.termux/files/usr/lib/libtermux-exec.so`.  
- [`-T`](#-t-1)  
    - `$PATH`: Only termux primary `bin` path: `/data/data/com.termux/files/usr/bin`  
    - `$LD_LIBRARY_PATH`:  
        - Android `>= 7`: Not set by default.  
        - Android `< 7`: `/data/data/com.termux/files/usr/lib`  
    - `$LD_PRELOAD`: `/data/data/com.termux/files/usr/lib/libtermux-exec.so`.  
- [`-TT`](#-tt)  
    - `$PATH`: All termux bin paths: `/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets`  
    - `$LD_LIBRARY_PATH`:  
        - Android `>= 7`: Not set by default.  
        - Android `< 7`: `/data/data/com.termux/files/usr/lib`  
    - `$LD_PRELOAD`: `/data/data/com.termux/files/usr/lib/libtermux-exec.so`.  

&nbsp;

If [`-t`](#-t) mode is engaged, like for `tudo su` command, then the `termux` bin paths will be prepended to `android` bin paths in the `$PATH` variable, which would give priority to `termux` binaries. That means that if an executable is executed that exists in both `termux` and `android` bin directories, then the `termux` one will be executed since it would be found first during the search. For example, running `ls` would execute `$TERMUX__PREFIX/bin/ls`.

If [`-a`](#-a) mode is engaged, like for `tudo asu` command, then the `android` bin paths will be prepended to `termux` bin paths in the `$PATH` variable, which would give priority to `android` binaries. That means that if an executable is executed that exists in both `termux` and `android` bin directories, then the `android` one will be executed since it would be found first during the search. For example, running `ls` would execute `/system/bin/ls`.

Note that if an absolute path to an executable is executed, like `/system/bin/ls`, then the `$PATH` variable will be not be used and its path priority will be irrelevant.

The same priority rules would apply for `$LD_LIBRARY_PATH`. If a library exists in both `termux` and `android` library directories, then the first one found will be used depending on the priority of paths in the variable regardless of if its compatible or not.

- To ensure only binaries under `$TERMUX__PREFIX/bin` directory are executed, pass the [`-T`](#-t-1) flag. **This will have consistent behaviour with shells starts by the Termux app.**  
- To ensure only binaries under any `termux` directory (`$TERMUX__PREFIX/bin` or `$TERMUX__PREFIX/bin/applets`) are executed, pass the [`-TT`](#-tt) flag.  
- To ensure only binaries under `/system/bin` directory are executed, pass the [`-A`](#-a-1) flag.  
- To ensure only binaries under any `android` bin directory are executed, pass the [`-AA`](#-aa) flag. **This will have consistent behaviour with shells starts by android [`adb`](https://developer.android.com/tools/adb).**  
- While running in a shell as the `Termux app` user, to run a single `android` system command as the `Termux app` user, use the [`path`](#path) command with the [`-A`](#-a-1) or [`-AA`](#-aa) flag as `tudo -A <command>`, like `tudo -A ls -lhdZ .` to execute `/system/bin/ls`.  
- You can also use the [`tpath` and `apath` functions](#tpath-and-apath-functions) if they are defined in the `rc` file of your interactive shell to shift priorities without starting a new shell.  

&nbsp;

If getting the linker error `CANNOT LINK EXECUTABLE` errors, with sub errors like `library <library> not found` and `cannot locate symbol <symbol> referenced by <executable/dependency_library>`, check Termux [`Dynamic Library Linking And Errors`](https://github.com/termux/termux-packages/wiki/Termux-execution-environment#dynamic-library-linking-and-errors) docs, especially [`Package dependencies are outdated`](https://github.com/termux/termux-packages/wiki/Termux-execution-environment#package-dependencies-are-outdated) and [`$LD_LIBRARY_PATH` contains incompatible directory paths](https://github.com/termux/termux-packages/wiki/Termux-execution-environment#ld_library_path-contains-incompatible-directory-paths) sections. Make sure packages are upto date and `$LD_LIBRARY_PATH` is not being set containing termux and android default library paths on Android `>= 7`. For Android `< 7`, since `$LD_LIBRARY_PATH` needs to be set, if a library exists in both termux and android system library path, which would cause conflicts.

## &nbsp;

&nbsp;



### `tpath` and `apath` functions

For the shells `bash zsh dash sh ksh fish`, additional functions named `tpath` and `apath`are added to their `rc` files under the `tudo` shell home if `rc` files did not already exist when `tudo` is run for the first time for a shell and its home, otherwise they are not added if `rc` file already existed. You can call these functions to set priorities from inside interactive shell sessions only when running `tudo su`, `tudo asu` or `tudo -is <core_script` commands, since they depend on some environment variables set by the `tudo` script and are not hard-coded in case of future changes.

The `tpath` function will set priority to termux bin paths in `$PATH` variable.

The `apath` function will set priority to android bin paths in `$PATH` variable.

The functions will use the inverted value for the priority flags passed for which current `tudo` instance was started with. For example, if `tudo` was run with [`-a`](#-a) flags, then running `tpath` would result in variables being set as per [`-t`](#-t) flag and running `apath` would invert them back to values as per [`-a`](#-a) flag. If `tudo` was started with [`-T`](#-t-1), then running `apath` would result in variables being set as per [`-A`](#-a-1) flag and running `tpath` would invert them back to values as per [`-T`](#-t-1) flag.

The functions allows the users to quickly switch priorities without having to switch between `tudo su` and `tudo asu` shells.

If you already have an existing `rc` file for your shell like `~/.bashrc` and want to add the functions to it. Either add them manually as per the functions below depending on your shell's syntax or just temporarily move (not copy) the file to somewhere else and run `tudo su` command with the optional [`--shell`](#--shell) option, then copy the functions from the new `rc` file created by `tudo` to your old file, then remove the new file and move the old file back.

**IMPORTANT:** If you updated from `tudo` version `<= 2.0.0` to `>= 3.0.0`, then you will have to update the `tpath` and `apath` functions in the respective shell's `rc` files under `tudo` shell home as older versions used hardcoded paths instead of `TUDO__` scoped environment variables that are dynamically exported for the current Termux rootfs and Android version when `tudo` is run.

The following functions are added for the `bash zsh dash sh ksh` shells. The `fish` shell has a different syntax.

```shell
tpath() {
    export PATH="$TUDO__TERMUX_PRIORITY_PATH";
    export LD_LIBRARY_PATH="$TUDO__TERMUX_PRIORITY_LD_LIBRARY_PATH";
    export LD_PRELOAD="$TUDO__TERMUX_LD_PRELOAD";
}

apath() {
    export PATH="$TUDO__ANDROID_PRIORITY_PATH";
    export LD_LIBRARY_PATH="$TUDO__ANDROID_PRIORITY_LD_LIBRARY_PATH";
    unset LD_PRELOAD;
}
```

## &nbsp;

&nbsp;



### `export` and `unset` functions

For the `fish` shell, additional functions named `export` and `unset` are also added to the `rc` files if the `tudo` script creates its `rc` file, they are not added otherwise. The functions port the `bash` `export var=value` and `unset var` functionality respectively.

## &nbsp;

&nbsp;



### `su` search paths

If [`-A`](#-a-1), [`-T`](#-t-1) or [`-TT`](#-tt) flags are not passed, and [`--su-bin-path-add=1`](#--su-bin-path-add) is passed to `tudo` or `TUDO__ADD_SU_BIN_PATH_TO_PATH_VARIABL=1` is exported, or is set in the `tudo.config` file, then `tudo` will search and add the `su` binary directory path to `$PATH`.

The `su` binary is searched at the following paths in order: `/system/bin/su`, `/debug_ramdisk/su`, `/system/xbin/su`, `/sbin/su`, `/sbin/bin/su`, `/system/sbin/su`, `/su/xbin/su`, `/su/bin/su`, `/magisk/.core/bin/su`

If a `su` binary is not found at any of the paths or if no `su` found contains the `-c`, `--shell`, `--preserve-environment` and `--mount-master` options in its `--help` output, then `tudo` will not add `su` binary directory to `$PATH` exported for `android` paths. You can specify a custom path by exporting it in `$TUDO__SU_PATH` or passing the [`--su-path`](#--su-pathpath) option if the `su` binary does not exist at the default search paths or all paths in it should not be checked.

- `/system/bin/su`: Used by `Magisk` and its `avd_patch.sh` script which patch the boot image/emulator ramdisk.  

     - https://github.com/topjohnwu/Magisk  
     - https://github.com/topjohnwu/Magisk/blob/v26.4/scripts/avd_patch.sh  

- `/debug_ramdisk/su`: Used by `Magisk` `>= 26.2` and its `avd_magisk.sh` script which live installs magisk on Android emulator (`AVD`). Previously was `/dev/avd-magisk/su`.  

    `Magisk` normally symlinks `/system/bin/sh` to `/system/bin/magisk`, which is a `tmpfs` mount to `/debug_ramdisk/magisk64`.  

    - https://github.com/topjohnwu/Magisk/commit/f9d22cf8ee43129af8a2a59cb228c5a77508809c  
    - https://github.com/topjohnwu/Magisk/blob/v26.2/native/src/init/rootdir.cpp#L214  
    - https://github.com/topjohnwu/Magisk/commit/19a4e11645912e4510f6848b9ec5d8619e6ceb0f  
    - https://github.com/topjohnwu/Magisk/blob/v26.4/scripts/avd_magisk.sh#L110  
    - https://github.com/topjohnwu/Magisk/blob/v26.4/docs/details.md#paths-in-magisk-tmpfs-directory  

- `/system/xbin/su`: Used by `SuperSU`. It's also used by the limited `su` provided by Android debug build for `adb root`, and it does not support the `-c`, `--shell`, `--preserve-environment` and `--mount-master` options.  

    Normally, debug build `su` will not be executable by app users, but if already running as `root` user, like nested `tudo` call inside [`sudo`], then it will be executable and `test -x` checks will pass. So we need `/system/bin/su` before `/system/xbin/su`, so that `Magisk` one is always chosen if running on debug emulator patched with `avd_patch.sh`, otherwise if order is revered, then first [`sudo`] call as app user will skip `/system/xbin/su` and choose `/system/bin/su`, but second nested `tudo` call as `root` user will choose `/system/xbin/su` first, which will be an issue since `tudo` does not check `su --help` output to see if `--shell`, `--preserve-environment` and `--mount-master` options are supported, which are not supported by debug build `su` but are often necessary for users.  

    - https://su.chainfire.eu/  
    - https://cs.android.com/android/platform/superproject/+/master:system/extras/su/su.cpp    
    - https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/sepolicy/private/file_contexts;l=310  

- Other paths are used by older versions (of/and other) `su` providers.

---

&nbsp;





## Tests

Check the [tudo_tests](https://github.com/agnostic-apollo/tudo/tree/master/tests/tudo_tests) script to run automated tests for the `tudo` script command types, options and shells. Usage instructions are inside the script. There are more examples for running `tudo` inside the `tudo_tests` script that can be used by users, although may not be too user friendly to view or understand.

---

&nbsp;





[Tasker]: https://play.google.com/store/apps/details?id=net.dinglisch.android.taskerm
[Termux]: https://github.com/termux/termux-app
[Termux:Tasker]: https://github.com/termux/termux-tasker
[QuickEdit]: https://play.google.com/store/apps/details?id=com.rhmsoft.edit
[QuickEdit Pro]: https://play.google.com/store/apps/details?id=com.rhmsoft.edit.pro
[Acode editor]: https://github.com/deadlyjack/code-editor
[Turbo Editor]: https://github.com/vmihalachi/turbo-editor

[SuperSU]: https://forum.xda-developers.com/t/beta-2017-10-01-supersu-v2-82-sr5.2868133/
[Magisk]: https://github.com/topjohnwu/Magisk

[`sudo`]: https://github.com/agnostic-apollo/sudo

[RUN_COMMAND Intent]: https://github.com/termux/termux-app/wiki/RUN_COMMAND-Intent

[Process Substitution]: https://en.wikipedia.org/wiki/Process_substitution
[Here Document]: https://en.wikipedia.org/wiki/Here_document
[Prompt String 1]: https://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html
