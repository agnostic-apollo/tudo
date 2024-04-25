---
page_ref: "@ARK_PROJECT__VARIANT@/agnostic-apollo/tudo/docs/@ARK_DOC__VERSION@/developer/test/index.md"
---

# tudo Test Docs

<!-- @ARK_DOCS__HEADER_PLACEHOLDER@ -->

[`tudo_tests`](https://github.com/agnostic-apollo/tudo/blob/master/tests/tudo_tests) can be used to run tests for [`tudo`](https://github.com/agnostic-apollo/tudo).

Check the `tudo_tests` file for setup instructions, or run it with the `--help-extra` option.

If `tudo` is installed with a Termux package manager, then `tudo_tests` gets installed at `$TERMUX__PREFIX/libexec/installed-tests/tudo/tudo_tests`.

To show help, run `${TERMUX__PREFIX:-$PREFIX}/libexec/installed-tests/tudo/tudo_tests --help-extra`.

To run all tests, run `${TERMUX__PREFIX:-$PREFIX}/libexec/installed-tests/tudo/tudo_tests -vv`. Tests will only be run for whatever shells are currently installed. The `--only-bash-tests` option can be passed to only test `bash` shell. Additionally, the `su`, `asu`, `path`, or `script` can be passed to only run tests for specific command types.

---

&nbsp;





## Help

```
tudo_tests is a script that run tests for the tudo script.


Usage:
  tudo_tests [command_options]
  tudo_tests [command_options] <su|asu|path|script>
  tudo_tests [command_options] <su|asu|path|script> <shell> <test_number>


Available command_options:
  [ -h | --help ]    Display this help screen.
  [ --help-extra ]   Display more help about how tudo_tests command
                     works.
  [ -q | --quiet ]   Set log level to 'OFF'.
  [ -v | -vv ]       Set log level to 'DEBUG', 'VERBOSE', `VVERBOSE'.
  [ --only-bash-tests ] Run only bash shell tests.


Setting log level '>= DEBUG' will fail test validation for tests that
match the output, its mainly for debugging.
```

---

&nbsp;
