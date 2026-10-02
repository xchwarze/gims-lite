# GIMS configuration reference

Reference for `settings.ini` and the engine INI files. Back to the [README](../README.md).

All configuration is plain INI (UTF-8, a BOM is accepted). Nothing is stored in the Windows
registry. Keys are case-sensitive, values may contain `#`, `;` and `%` (no inline comments, no
interpolation), a line starting with `#` or `;` is a comment, and duplicate keys in an engine INI
are an error. Check engine files with `gims engines validate`.

## settings.ini

`config/settings.ini` holds one `[settings]` section. It is created with defaults on the first
run (a read-only folder is tolerated), edited by the GUI **Options** and **Profiles** dialogs,
and rewritten atomically; unknown keys and sections are preserved. An invalid value falls back
to its default and is reported as a diagnostic.

| Key | Default | Meaning |
|---|---|---|
| `schema_version` | `1` | Only `1` is accepted. |
| `scan_mode` | `file` | `file`, `folder-report` or `folder-report-delete`. See [CLI.md](CLI.md). |
| `profiles` | `low,medium,high` | Ordered, comma-separated profile names. |
| `default_profile` | `high` | Profile used when none is requested; must be in `profiles`. |
| `default_timeout_seconds` | `300` | Time limit for scans and tools that do not set their own. Must be a positive number; `0` is rejected here on purpose. |
| `selected_engine_ids` | available engines with `preselect = true` | Comma-separated engines a scan runs by default (they run in the engines' `order`, not the order listed). Seeded on the first run; an explicitly empty value stays empty. |
| `save_raw_output` | `false` | Keep every engine's raw output under `reports/`. See below. |
| `show_unavailable_engines` | `true` | GUI: list engines whose executable is missing. |
| `show_debug_information` | `false` | GUI: open the debug window at startup. |
| `run_as_admin` | `false` | GUI: restart GIMS elevated (UAC prompt) every time it starts. Drag and drop from Explorer does not work in an elevated window. If the prompt is cancelled GIMS opens normally. Takes effect at the next start. |
| `allow_multiple_instances` | `false` | GUI: allow several windows at once. Off by default: a second launch from the same installation folder brings the running window forward and exits. Takes effect at the next start. |
| `theme` | `system` | `system`, `light` or `dark` (GUI). |
| `language` | `en` | Only `en` exists. |
| `download_dir` | `downloads` | Where downloaded archives go (`{download_dir}`). |
| `tools_dir` | `bin` | Where helper tools live (`{tools_dir}`); it and each subfolder are put on the `PATH` of every command. |
| `engines_dir` | `engines` | Where engines are installed (`{engines_dir}`), one folder each. |

The three directory keys accept absolute paths or paths relative to the install root, and
reject the characters `< > " | ? *` and control characters. The install root is the parent of
the config directory. Engine definitions always live in `config/engines/`; `engines_dir` is only
where engines are installed.

Profiles are names made of lowercase letters, digits, `_` and `-`, starting with a letter or
digit. The last profile cannot be deleted; deleting the default profile promotes the first
remaining one.

With `save_raw_output = true` each scan creates `reports/YYYYMMDD-HHMMSS-ffffff/`. A file scan
stores `<engine_id>.output.txt`; a folder scan stores `NNNN-<engine_id>.output.txt` per file plus
`index.json`; before/after-scan command output is stored as `<engine_id>.before_scan.txt` and
`<engine_id>.after_scan.txt`.

## Engine INI files

One file per engine in `config/engines/`; the file name (without `.ini`) must equal `engine_id`.
Unknown sections and unknown keys are errors. Repeated values use numbered keys `name.01`,
`name.02`, ...: two digits from `01` to `09`, then `10` and up; numbering must start at `.01`,
indexes may not repeat, and values may not be empty. Commands are argument lists (no shell): one
argument per key, no quoting needed.

Placeholders such as `{target}` and `{engine_dir}` may appear in arguments and in `report_path`;
where each is valid, and the matching `GIMS_*` environment variables, are in
[VARIABLES.md](VARIABLES.md). A placeholder used where it is not valid is a validation error.

### [engine]

| Key | Required | Meaning |
|---|---|---|
| `schema_version` | yes | Must be `1`. |
| `engine_id` | yes | `[a-z0-9][a-z0-9_-]*`, equal to the file name. Unique across files (the first file loaded wins). |
| `display_name` | yes | Name shown in the GUI and results. |
| `engine_type` | yes | `antivirus` or `tool`. |
| `executable_path` | yes | The engine's executable. Absolute, or relative to the install root; a bare name is looked up on `PATH`. An engine is *available* when this file exists. Its folder is `{engine_dir}`. |
| `preselect` | no (`true`) | Only seeds `selected_engine_ids` on the first run. It does not enable or disable the engine. |
| `icon_path` | no | Icon shown in the GUI engine lists: a PNG only (checked by its signature, not its extension), at most 1 MiB; 32x32 fits best. An existing file that is not a valid PNG is `INVALID_FIELD`; a missing file just shows the default icon of the engine type. |
| `order` | no (`0`) | Integer run priority: negative runs earlier, positive later. Engines sort by `order`, then display name (case-insensitive), then `engine_id`; that order drives the engine list, scans (also `--engine`), and `download`/`update --all`. Anything but a plain integer is `INVALID_FIELD`. |

### [scan] (both engine types)

An antivirus and a tool share one command model: the program is `[engine] executable_path`, and
`[scan]` holds its arguments. The command GIMS runs is `executable_path` followed by the arguments
of the selected profile.

| Key | Default | Meaning |
|---|---|---|
| `argument.NN` | required | Default arguments (arguments only, not the program). Used by every profile that has no list of its own. Must contain `{target}`. |
| `argument.<profile>.NN` | default arguments | Arguments for one profile; the list REPLACES the default one (nothing is concatenated). Any well-formed profile name is accepted, even one `settings.ini` does not list. Must contain `{target}`. |
| `timeout_seconds` | `default_timeout_seconds` | Wall-clock limit per scan. Empty or absent means the default (300 s unless changed), `0` means no limit, `N` means `N` seconds. |
| `hide_execution` | `true` | Tools only: see "Execution mode". An antivirus scan command is always hidden, so the key is rejected there. |
| `run_as_invoker` | `false` | Start the scan and `before_scan`/`after_scan` commands with `__COMPAT_LAYER=RunAsInvoker` (added to any layers already set), so a program whose manifest asks for administrator rights runs with the rights GIMS has instead of failing to start. Not applied to `[download]`/`[update]`. What really needs administrator rights (drivers, memory of other programs) may then not work. |
| `lower_priority` | `false` | Start those same commands at below-normal priority (Windows), so scanning does not slow down the rest of a shared machine. Little use on a computer dedicated to scanning. |
| `before_scan_command.NN` | none | Command run once before the engine's scans (for example to start a daemon). |
| `after_scan_command.NN` | none | Command run once after them. |
| `before_scan_detach` | `false` | Start `before_scan_command` as a background process that lives for the whole run and is terminated afterwards (needs `before_scan_command`). |
| `before_scan_ready_seconds` | `2` | How long to wait after a detached start before scanning; must be shorter than the scan timeout. |
| `before_scan_hide_execution` | `true` | See "Execution mode". |
| `after_scan_hide_execution` | `true` | See "Execution mode". |

The two engine types differ only in how the result is judged. An **antivirus** is judged by its
`[parser]` (clean, detected, error...), so its scan command is always run hidden and its output is
captured. A **tool** prints information instead of judging a file: `SUCCESS` or `ERROR` by exit
code, output shown, never counted as a detection; it has no parser rules. There is no `[tool]`
section and no `tool_command` key: the old `[tool]` keys now live in `[scan]` (arguments, timeout,
lifecycle, `hide_execution`) and `[parser]` (result source), and `scan_argument` is now `argument`.
The old names are unknown-field errors.

### [parser]

A tool's `[parser]` may only hold the result-source keys (`result_source`, `report_path`,
`report_encoding`) and `info_regex`; everything else below is antivirus-only, and `info_regex` is
rejected (`INVALID_FIELD`) in an antivirus INI.

`parser_type` is `regex` or `exit_code` (`delimiters`, with `detection_delimiter.NN.left|right`,
is a legacy form kept for old files; write regexes instead). Regexes are Python `re` patterns
applied to the merged stdout and stderr, in arrival order. In an INI, leading or trailing spaces
of a value are trimmed, so write them as `\x20`.

| Key | Default | Meaning |
|---|---|---|
| `parser_type` | required | `regex`: needs at least one `detection_regex`. `exit_code`: needs `clean_exit_codes` and `detected_exit_codes`. |
| `detection_regex` / `detection_regex.NN` | | Each match is a detection. Must define the named group `(?P<detection>...)`; optional groups `file` and `message`. |
| `error_regex` / `error_regex.NN` | | A match means the scan is an `ERROR` (checked before detections). The text of group `error`, or the whole match, is the message. |
| `ignore_regex` / `ignore_regex.NN` | | A detection whose whole name matches is discarded (for example summary lines). |
| `output_encoding` | `utf-8` | Encoding of the console output; a UTF-8 or UTF-16 BOM overrides it. |
| `clean_exit_codes` | `0` | Comma-separated exit codes meaning clean. |
| `detected_exit_codes` | | Exit codes meaning detected. With `regex`, used only when nothing matched. Must not overlap `clean_exit_codes`. |
| `result_source` | `stdout` | `stdout` or `report_file`. |
| `report_path` | | Required with `report_file`; see below. |
| `report_encoding` | `auto` | See below. |
| `info_regex` | | Tools only. Regex with a required named group `(?P<info>...)`, searched (`re.search`, no flags) in the result text (stdout, or the report file). The first match's `info`, stripped, is the tool's INFO, shown next to its status and stored in the JSON report as `results[].info` (`null` when there is no regex or it does not match; the tool then still succeeds, with the message `no info matched`). A tool is never a detection, whatever it prints. Example (RHash): `(?i)\b(?P<info>[0-9a-f]{40})\b` picks the SHA1. |

Verdict order: cancelled, timeout, launch failure, then `error_regex`, then detections, then the
exit code (in `clean_exit_codes` is clean, in `detected_exit_codes` is detected, anything else is
an error). A regex parser that finds no detection is clean only through its exit code.

### Result from a report file

Some scanners write their verdict to a file instead of the console. Set
`result_source = report_file` and `report_path` in `[parser]` (both engine types). `report_path` may use every placeholder except `{report_path}`; `{temp_dir}` gives a
fresh per-run folder. The scan command must pass the resolved path as `{report_path}` in every
`argument` list (default and profiles). GIMS deletes a stale report before
each run, reads the new one, and reports `ERROR` if it was not produced. The raw output keeps the
console text and appends the report after a `--- report file <path> ---` marker.
`report_encoding` is `auto` (UTF-16 or UTF-8 BOM, else UTF-8, else cp1252) or any Python codec
name.

### [download] and [update]

Both sections are optional and identical. They run a command that installs or refreshes the
engine; GIMS does not parse URLs or pages, the command (usually a script) does the work.

| Key | Default | Meaning |
|---|---|---|
| `download_command.NN` / `update_command.NN` | required for the section | The command line. |
| `timeout_seconds` | no limit | Absent, empty or `0` mean no limit; `N` is `N` seconds. The global default never applies. |
| `success_exit_codes` | `0` | Comma-separated exit codes that mean success. |
| `hide_execution` | `true` | See "Execution mode". |

### Execution mode: hide_execution

Every configurable command has a `hide_execution` flag, `true` by default (`hide_execution` in
`[download]`, `[update]` and, for a tool's scan command, `[scan]`; `before_scan_hide_execution`
and `after_scan_hide_execution` for the lifecycle commands). Hidden runs capture the output and close
stdin. With `false` the command runs in normal mode: it shares the terminal (or opens its own
console window when GIMS runs windowed) so a person can interact with it; its output is not
captured, but its exit code, timeout and cancellation still apply. `gims --json` refuses to run
such commands, and `before_scan_detach = true` cannot be combined with
`before_scan_hide_execution = false`.

### Timeouts at a glance

| Command | Empty or absent | `0` | `N` |
|---|---|---|---|
| Scan and lifecycle (`[scan]`) | `default_timeout_seconds` (300 s) | no limit | `N` seconds |
| `[download]`, `[update]` | no limit | no limit | `N` seconds |

On timeout or cancel GIMS terminates the whole process tree.

## Examples

Two engines ship in `release/config/engines/`; the third-party programs they download are not
part of GIMS.

`vba32.ini` is an antivirus engine whose verdict comes from a report file, with one argument
list per profile and a download script:

```ini
[engine]
schema_version = 1
engine_id = vba32
display_name = VBA32
engine_type = antivirus
preselect = false
executable_path = engines/vba32/vba32w.exe

[scan]
argument.01 = {target}
argument.02 = /R={report_path}
argument.03 = /HA=0
argument.high.01 = {target}
argument.high.02 = /R={report_path}
argument.high.03 = /HA=3

[parser]
parser_type = regex
result_source = report_file
report_path = {temp_dir}\reportVBA32.txt
report_encoding = auto
detection_regex.01 = (?i)\x20infected\x20(?P<detection>[^\r\n]+)
ignore_regex.01 = \s*:\s*\d+\s*

[download]
download_command.01 = cmd.exe
download_command.02 = /c
download_command.03 = {install_root}\scripts\install-vba32.bat
download_command.04 = https://anti-virus.by/download_files/install/VBA32CSW/vba32w.7z
timeout_seconds = 0
```

(Abbreviated; the shipped file has more arguments and the `[update]` twin.)

`rhash.ini` is a tool engine that prints hashes and is not selected by default; the program is only named in `executable_path`:

```ini
[engine]
schema_version = 1
engine_id = rhash
display_name = RHash
engine_type = tool
preselect = false
executable_path = engines/rhash/rhash.exe

[scan]
argument.01 = --md5
argument.02 = --sha256
argument.03 = --simple
argument.04 = {target}
timeout_seconds = 600
```

The install scripts, `release/scripts/install-vba32.bat` and `install-rhash.bat`, show how a
script uses the injected variables.
