# Variables in GIMS

Placeholders and `GIMS_*` environment variables available to engine commands and scripts. Back to the [README](../README.md).

GIMS gives engine definitions and the scripts they run two ways to learn where things are and what is being
processed:

- **Placeholders** such as `{target}`, written inside the arguments of a command in an engine INI. GIMS replaces
  them before it launches the command.
- **Environment variables** such as `GIMS_TARGET`, which every command GIMS runs receives. A `.bat` script uses them
  as `%GIMS_TARGET%`. This is what lets an install or update script stay free of hardcoded paths.

Both come from the same list: each placeholder has a matching `GIMS_*` variable (`{engines_dir}` is
`GIMS_ENGINES_DIR`, and so on). The single source of truth is `gims/core/variables.py`; the **Variables** window
of the engine editor shows the same catalog.

## Where a placeholder can be used

| Context | Where in the engine INI |
|---|---|
| `argument` | `argument.NN` and `argument.<profile>.NN` (antivirus and tool) |
| `lifecycle` | `before_scan_command.NN` and `after_scan_command.NN` |
| `download` | `download_command.NN` |
| `update` | `update_command.NN` |
| `report_path` | the `report_path` value |

A placeholder used somewhere it is not valid is a validation error, and the editor points at it before you save.

## Placeholders and their environment variables

| Placeholder | Environment variable | Valid in | What it is |
|---|---|---|---|
| `{target}` | `GIMS_TARGET` | argument, report_path | Absolute path of the file being scanned. Every scan command must contain it. Scans only. |
| `{profile}` | `GIMS_PROFILE` | argument, report_path | Name of the scan profile in use. Scans only. |
| `{report_path}` | `GIMS_REPORT_PATH` | argument | The engine's resolved `report_path`. Only exists when `result_source = report_file` (see below). |
| `{engine_id}` | `GIMS_ENGINE_ID` | all | The engine's `engine_id`. |
| `{engine_dir}` | `GIMS_ENGINE_DIR` | all | Folder that contains the engine's executable. It can be resolved before the engine is installed. |
| `{engines_dir}` | `GIMS_ENGINES_DIR` | all | Where engines are **installed**: `<install_root>/engines`. One folder per engine (`engines/<name>/`). |
| `{tools_dir}` | `GIMS_TOOLS_DIR` | all | Where helper tools such as `7z` and `wget` live: `<install_root>/bin`. Not for engines. |
| `{download_dir}` | `GIMS_DOWNLOAD_DIR` | all | Where downloaded archives go: `<install_root>/downloads`. Created before a download or update command runs. |
| `{install_root}` | `GIMS_INSTALL_ROOT` | all | The GIMS installation root, where relative executables, reports, logs and scripts live. |
| `{config_dir}` | `GIMS_CONFIG_DIR` | all | Folder that holds `settings.ini` and `engines/*.ini`. |
| `{temp_dir}` | `GIMS_TEMP_DIR` | all | A temporary folder GIMS creates per engine and operation and removes afterwards. Shared by `before_scan`, every scan of that engine and `after_scan`. |
| `{{` and `}}` | — | all | Literal `{` and `}`. Example: `--json={{}}` becomes `--json={}`. |

There is one more environment variable that has no placeholder: `GIMS_OPERATION`, which says what kind of command
is running: `scan`, `tool`, `before_scan`, `after_scan`, `download` or `update`.

Notes:

- `{engines_dir}` and the INI files are different things. **Definitions** live in `config/engines/*.ini`;
  **installed engines** live in `engines/<name>/`.
- The environment variables that do not exist for a run are left **unset**, not set to an empty string, so
  `if defined GIMS_TARGET` works in a `.bat`. `GIMS_TARGET`, `GIMS_PROFILE` and `GIMS_REPORT_PATH` exist only while
  scanning, and `GIMS_REPORT_PATH` only for engines that read their result from a report file.
- GIMS's own environment is never changed. The command gets a copy of the current environment plus these variables.
- Values are plain paths, without quotes. Quote them yourself in a `.bat`: `"%GIMS_ENGINE_DIR%"`.

## The PATH of the command

The command's `PATH` starts with `GIMS_TOOLS_DIR` and then each of its immediate subfolders, in alphabetical order,
followed by the existing `PATH`. With one folder per tool (`bin\7z\7z.exe`, `bin\wget\wget.exe`) a script can call
`7z` or `wget` directly. Calling them by full path also works and is more explicit:

```bat
"%GIMS_TOOLS_DIR%\wget\wget.exe" --no-verbose -O "%GIMS_DOWNLOAD_DIR%\rhash.zip" "%~1"
```

## Changing the folders

`settings.ini` has three optional keys. Empty or missing means the default.

```ini
[settings]
download_dir =
tools_dir =
engines_dir =
```

A relative value is resolved against the install root. A value with characters no Windows path can contain is
discarded with a diagnostic. Defaults: `downloads`, `bin` and `engines`.

## Examples

### Scan arguments

```ini
[scan]
argument.01 = {target}
argument.02 = /R={report_path}
```

### An engine that writes its verdict to a file

```ini
[parser]
result_source = report_file
report_path = {temp_dir}\report.txt
```

Rules that GIMS enforces for `result_source = report_file`:

- `report_path` must be filled in.
- `{report_path}` must appear in the argument list that produces the result: the default `argument.NN` list and
  every `argument.<profile>.NN` list the engine defines (a profile's list replaces the default list), for an
  antivirus and for a tool alike.
- With `result_source = stdout`, `{report_path}` is not allowed.

### An install or update command

The command is `cmd.exe /c <script> <url>`. Everything else comes from the environment:

```ini
[download]
download_command.01 = cmd.exe
download_command.02 = /c
download_command.03 = {install_root}\scripts\install-rhash.bat
download_command.04 = https://sourceforge.net/projects/rhash/files/latest/download
timeout_seconds = 0
```

```bat
@echo off
setlocal EnableExtensions
if "%~1"=="" exit /b 2
if not defined GIMS_ENGINE_DIR exit /b 2

"%GIMS_TOOLS_DIR%\wget\wget.exe" --no-verbose -O "%GIMS_DOWNLOAD_DIR%\rhash.zip" "%~1"
if errorlevel 1 exit /b 5

"%GIMS_TOOLS_DIR%\7z\7z.exe" x -y -o"%GIMS_ENGINE_DIR%" "%GIMS_DOWNLOAD_DIR%\rhash.zip"
if errorlevel 1 exit /b 6

del /q "%GIMS_DOWNLOAD_DIR%\rhash.zip"
exit /b 0
```

Exit with a non-zero code when a step fails, so GIMS reports the operation as failed. The two complete, working
scripts are `release/scripts/install-vba32.bat` and `release/scripts/install-rhash.bat`.

To see a command with its placeholders expanded, run `gims engines show <id>`.

## Regex groups

The `detection_regex`, `error_regex`, `ignore_regex` and (tools only) `info_regex` settings read **named groups** from a match.

| Group | Used in | Required | Meaning |
|---|---|---|---|
| `detection` | `detection_regex` | yes | Threat name. A match whose group is empty is skipped. |
| `file` | `detection_regex` | no | The file the detection refers to. The scanned target is used when it is missing or empty. |
| `message` | `detection_regex` | no | Extra text kept as the result message. The first non-empty one wins. |
| `error` | `error_regex` | no | Message shown for the ERROR result. The whole match is used when the group is missing. |
| `info` | `info_regex` | yes | Tools only: the text shown as the tool's INFO (never a detection). The first match wins; without a match the tool still succeeds, with no info. |
| (none) | `ignore_regex` | — | Takes no groups. It must match the **entire** detection name to discard it. |

Rules:

- Patterns use Python `re` syntax and no flags are added. Use `(?i)` for case-insensitive matching, `(?m)` so `^`
  and `$` match at each line, and `(?s)` so `.` matches line breaks.
- Line endings are **not** translated, so output from Windows programs contains `\r\n`. End line patterns with
  `\r?$` and exclude line breaks from names with `[^\r\n]`.
- `error_regex` is evaluated first. When it matches, the result is ERROR and `detection_regex` is not consulted.
- The text that is parsed is the process output, or the report file when `result_source = report_file`.
- INI values are not unescaped: write `\r`, not `\\r`.

Examples:

| For | Pattern | Output it matches | Result |
|---|---|---|---|
| `detection_regex` | `(?m)^FOUND (?P<detection>[^\r\n]+)\r?$` | `FOUND Eicar-Test-Signature` | detection = `Eicar-Test-Signature` |
| `detection_regex` | `(?m)^(?P<file>.+?): (?P<detection>[^\r\n]+) FOUND\r?$` | `C:\s\a.exe: Win.Test.EICAR_HDB-1 FOUND` | file = `C:\s\a.exe`, detection = `Win.Test.EICAR_HDB-1` |
| `error_regex` | `(?m)^ERROR: (?P<error>[^\r\n]+)` | `ERROR: database is out of date` | ERROR, message = `database is out of date` |
| `info_regex` | `(?i)\b(?P<info>[0-9a-f]{40})\b` | `da39a3ee5e6b4b0d3255bfef95601890afd80709  C:\s\a.exe` (rhash `--sha1 --simple`) | info = `da39a3ee5e6b4b0d3255bfef95601890afd80709` |
| `ignore_regex` | `Heur\..*` | a detection named `Heur.Generic` | the detection is ignored |

The engine editor tests a pattern against sample text in its **Regex tester**.
