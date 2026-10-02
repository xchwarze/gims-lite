# Third-party notices

Back to the [README](../README.md).

These notices cover third-party components only; the GIMS code itself is proprietary and all
rights are reserved (see [`LICENSE`](../LICENSE)).

`gims.exe` and `gims-gui.exe` are PyInstaller `--onefile` executables, and a distribution also
carries helper programs and example engine definitions. Licenses require some notices to travel
with binary distributions, so `tools/build_exe.py` copies this file next to the executables.
Versions are those locked in `uv.lock` for the release build, and license texts were read from the
installed distribution metadata of those exact versions. Anything that could not be confirmed from
a file is marked "(verify before release)".

Contents: [1. Inside the executables](#1-components-inside-the-executables),
[2. Helper programs in `bin/`](#2-helper-programs-shipped-in-bin),
[3. Example engines and what they download](#3-example-engines-and-downloaded-software),
[4. Build-time tools not shipped](#4-build-time-and-development-tools-not-shipped).

## 1. Components inside the executables

| Component | Version | In | License | Copyright holder |
|---|---|---|---|---|
| CPython runtime and standard library | 3.13 (3.13.15 in the reference build environment; the release build uses the CI runner's 3.13) | both | Python Software Foundation License 2.0 | Python Software Foundation |
| Tcl/Tk (bundled with CPython) | Tcl 8.6.15; the Tk patch level is not recorded in the installed files | `gims-gui.exe` | Tcl/Tk license (BSD-style) | Regents of the University of California, Sun Microsystems, Scriptics, ActiveState, Apple and others |
| PyInstaller bootloader and runtime | 6.22.3 | both | GPL-2.0-or-later with the Bootloader Exception (bootloader); Apache-2.0 (run-time hooks and modules) | PyInstaller Development Team |
| sv-ttk (Sun Valley ttk theme, including its theme assets) | 2.6.1 | `gims-gui.exe` | MIT | rdbende |
| tkinterdnd2 | 0.6.3 | `gims-gui.exe` | MIT | Philippe Gagné and contributors |
| tkdnd (native library inside tkinterdnd2, `win-x64` only) | 2.10.2 | `gims-gui.exe` | Tcl/Tk-style permissive license | Georgios Petasis; Mac portions Kevin Walzer / WordTech Communications LLC |
| darkdetect | 0.8.0 | `gims-gui.exe` | BSD-3-Clause | Alberto Sottile |
| pywinstyles (Windows only) | 1.8 | `gims-gui.exe` | CC0 1.0 Universal | Akash Bora |
| Microsoft Fluent System Icons (Regular), pre-rendered as the PNG files in `gims/gui/icons/assets/` | 1.1.261 | `gims-gui.exe` | MIT | Microsoft Corporation |

What `tools/build_exe.py` bundles: PyInstaller with the CPython runtime into both executables;
into `gims-gui.exe` additionally `sv_ttk`, `darkdetect`, `tkinterdnd2` and `pywinstyles` (hidden
imports; the hooks pick up the theme files and only the matching `win-x64` tkdnd library), the
application icon and the icon PNGs. The console `gims.exe` contains no GUI package.

### CPython

The Windows build of CPython also embeds Microsoft Distributable Code (the C runtime linked into
every `.exe`, `.dll` and `.pyd`); its redistribution conditions are quoted near the end of the
Python distribution's `LICENSE.txt`, together with the licenses of other components that
distribution includes (for example bzip2/libbzip2 1.0.8). Which of those extension modules end up
inside the frozen executables depends on the modules imported at build time
(verify before release). The Python license, from that `LICENSE.txt`:

```text
PYTHON SOFTWARE FOUNDATION LICENSE VERSION 2
--------------------------------------------

1. This LICENSE AGREEMENT is between the Python Software Foundation
("PSF"), and the Individual or Organization ("Licensee") accessing and
otherwise using this software ("Python") in source or binary form and
its associated documentation.

2. Subject to the terms and conditions of this License Agreement, PSF hereby
grants Licensee a nonexclusive, royalty-free, world-wide license to reproduce,
analyze, test, perform and/or display publicly, prepare derivative works,
distribute, and otherwise use Python alone or in any derivative version,
provided, however, that PSF's License Agreement and PSF's notice of copyright,
i.e., "Copyright (c) 2001-2024 Python Software Foundation; All Rights Reserved"
are retained in Python alone or in any derivative version prepared by Licensee.

3. In the event Licensee prepares a derivative work that is based on
or incorporates Python or any part thereof, and wants to make
the derivative work available to others as provided herein, then
Licensee hereby agrees to include in any such work a brief summary of
the changes made to Python.

4. PSF is making Python available to Licensee on an "AS IS"
basis.  PSF MAKES NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR
IMPLIED.  BY WAY OF EXAMPLE, BUT NOT LIMITATION, PSF MAKES NO AND
DISCLAIMS ANY REPRESENTATION OR WARRANTY OF MERCHANTABILITY OR FITNESS
FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF PYTHON WILL NOT
INFRINGE ANY THIRD PARTY RIGHTS.

5. PSF SHALL NOT BE LIABLE TO LICENSEE OR ANY OTHER USERS OF PYTHON
FOR ANY INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES OR LOSS AS
A RESULT OF MODIFYING, DISTRIBUTING, OR OTHERWISE USING PYTHON,
OR ANY DERIVATIVE THEREOF, EVEN IF ADVISED OF THE POSSIBILITY THEREOF.

6. This License Agreement will automatically terminate upon a material
breach of its terms and conditions.

7. Nothing in this License Agreement shall be deemed to create any
relationship of agency, partnership, or joint venture between PSF and
Licensee.  This License Agreement does not grant permission to use PSF
trademarks or trade name in a trademark sense to endorse or promote
products or services of Licensee, or any third party.

8. By copying, installing or otherwise using Python, Licensee
agrees to be bound by the terms and conditions of this License
Agreement.
```

The full `LICENSE.txt` is also available at https://docs.python.org/3/license.html.

### PyInstaller

The bootloader and the runtime files embedded in every frozen executable are covered by the
license below, which includes the Bootloader Exception that allows distributing them inside
programs that are not GPL. The run-time hooks (`PyInstaller/hooks/rthooks`) and the additional
run-time modules embedded in the executable are Apache License 2.0
(https://www.apache.org/licenses/LICENSE-2.0). The hooks provided by `pyinstaller-hooks-contrib`
2026.7 are used at build time; any of its run-time hooks embedded in the executables are
Apache-2.0 or GPL-2.0 licensed per that package (verify before release). Source of PyInstaller:
https://github.com/pyinstaller/pyinstaller. Relevant part of `COPYING.txt` from PyInstaller 6.22.3 (the remainder concerns build-time code and the isolated submodule):

```text
================================
 The PyInstaller licensing terms
================================


Copyright (c) 2010-2023, PyInstaller Development Team
Copyright (c) 2005-2009, Giovanni Bajo
Based on previous work under copyright (c) 2002 McMillan Enterprises, Inc.


PyInstaller is licensed under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2 of the License,
or (at your option) any later version.


Bootloader Exception
--------------------

In addition to the permissions in the GNU General Public License, the
authors give you unlimited permission to link or embed compiled bootloader
and related files into combinations with other programs, and to distribute
those combinations without any restriction coming from the use of those
files. (The General Public License restrictions do apply in other respects;
for example, they cover modification of the files, and distribution when
not linked into a combined executable.)


Bootloader and Related Files
----------------------------

Bootloader and related files are files which are embedded within the
final executable. This includes files in directories:

./bootloader/
./PyInstaller/loader


Run-time Hooks
----------------------------

Run-time Hooks are a different kind of files embedded within the final
executable. To ease moving them into a separate repository, or into the
respective project, these files are now licensed under the Apache License,
Version 2.0.

Run-time Hooks are in the directory
./PyInstaller/hooks/rthooks


Additional Run-time Modules
----------------------------------

In addition to run-time hooks, PyInstaller may embed additional run-time
modules in the final executable. At the time of writing, these include
the splash-screen module (``pyi_splash``) and modules from utility package
for run-time hooks (``_pyi_rth_utils``). All these files are licensed under
the Apache License, Version 2.0, and are located in the following directory:

./PyInstaller/fake-modules
```

### Tcl/Tk

Tk 8.6 (`tcl/tk8.6/license.terms` of the CPython distribution used for the build):

```text
This software is copyrighted by the Regents of the University of
California, Sun Microsystems, Inc., Scriptics Corporation, ActiveState
Corporation, Apple Inc. and other parties.  The following terms apply to
all files associated with the software unless explicitly disclaimed in
individual files.

The authors hereby grant permission to use, copy, modify, distribute,
and license this software and its documentation for any purpose, provided
that existing copyright notices are retained in all copies and that this
notice is included verbatim in any distributions. No written agreement,
license, or royalty fee is required for any of the authorized uses.
Modifications to this software may be copyrighted by their authors
and need not follow the licensing terms described here, provided that
the new terms are clearly indicated on the first page of each file where
they apply.

IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
MODIFICATIONS.

GOVERNMENT USE: If you are acquiring this software on behalf of the
U.S. government, the Government shall have only "Restricted Rights"
in the software and related documentation as defined in the Federal
Acquisition Regulations (FARs) in Clause 52.227.19 (c) (2).  If you
are acquiring the software on behalf of the Department of Defense, the
software shall be classified as "Commercial Computer Software" and the
Government shall have only "Restricted Rights" as defined in Clause
252.227-7013 (b) (3) of DFARs.  Notwithstanding the foregoing, the
authors grant the U.S. Government and others acting in its behalf
permission to use and distribute the software in accordance with the
terms specified in this license.
```

### sv-ttk

License file of sv-ttk 2.6.1 (covers the Sun Valley theme assets it ships):

```text
MIT License

Copyright (c) rdbende <rdbende@proton.me>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### tkinterdnd2

License file of tkinterdnd2 0.6.3:

```text
MIT License

Copyright (c) 2020 Philippe Gagné

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### tkdnd

The tkdnd 2.10.2 native library ships inside tkinterdnd2 without a license file. The text below is
`license.terms` from the upstream repository https://github.com/petasis/tkdnd, read from its
default branch; confirm it matches release 2.10.2 (verify before release):

```text
This software is copyrighted by:
   Georgios Petasis, Athens, Greece.
   e-mail: petasisg@yahoo.gr, petasis@iit.demokritos.gr

   Mac portions (c) 2009-2014 Kevin Walzer/WordTech Communications LLC,
   kw@codebykevin.com

The following terms apply to all files associated with the
software unless explicitly disclaimed in individual files.

The authors hereby grant permission to use, copy, modify, distribute,
and license this software and its documentation for any purpose, provided
that existing copyright notices are retained in all copies and that this
notice is included verbatim in any distributions. No written agreement,
license, or royalty fee is required for any of the authorized uses.
Modifications to this software may be copyrighted by their authors
and need not follow the licensing terms described here, provided that
the new terms are clearly indicated on the first page of each file where
they apply.

IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
MODIFICATIONS.

GOVERNMENT USE: If you are acquiring this software on behalf of the
U.S. government, the Government shall have only "Restricted Rights"
in the software and related documentation as defined in the Federal
Acquisition Regulations (FARs) in Clause 52.227.19 (c) (2).  If you
are acquiring the software on behalf of the Department of Defense, the
software shall be classified as "Commercial Computer Software" and the
Government shall have only "Restricted Rights" as defined in Clause
252.227-7013 (c) (1) of DFARs.  Notwithstanding the foregoing, the
authors grant the U.S. Government and others acting in its behalf
permission to use and distribute the software in accordance with the
terms specified in this license.
```

### darkdetect

License file of darkdetect 0.8.0:

```text
Copyright (c) 2019, Alberto Sottile
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of "darkdetect" nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL "Alberto Sottile" BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

### pywinstyles

pywinstyles 1.8 is released under Creative Commons Zero v1.0 Universal (CC0 1.0), a public domain
dedication; no attribution is required. Full text:
https://creativecommons.org/publicdomain/zero/1.0/legalcode

### Microsoft Fluent System Icons

The icons on buttons and result rows are rasterized from Microsoft Fluent System Icons (Regular),
upstream release 1.1.261 (as recorded by the `tkinter-icons-fluent-reg` 1.1.0 package used to render
them), and shipped as PNG images. Upstream: https://github.com/microsoft/fluentui-system-icons.
The redistributing package's own copy of the MIT text (`LICENSES/MIT.txt`) does not carry the
copyright line; the text below is the upstream `LICENSE` file, which does:

```text
MIT License

Copyright (c) 2020 Microsoft Corporation

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 2. Helper programs shipped in `bin/`

`release/bin/` holds programs that are shipped next to the executables as separate files. They
are independent programs that GIMS runs as child processes and install scripts call; they are not
linked into `gims.exe` or `gims-gui.exe`. Their license files are in their folders and ship with
them (`bin/wget/COPYING`, `bin/7z/License.txt`); `bin/lessmsi/` ships none (see its entry).

### GNU Wget

| | |
|---|---|
| Program | GNU Wget, `bin/wget/wget.exe` |
| License | GNU General Public License version 3 (`bin/wget/COPYING`, "Version 3, 29 June 2007"); documentation `wget.html` under the GNU Free Documentation License 1.3 or later |
| Copyright | Free Software Foundation, Inc. (`wget.html`: 1996-2011, 2015, 2018-2023) |
| Version | not stated in the shipped files (`wget.exe` and `wget.html` are dated 2023-05-11) (verify before release) |
| Built by | not stated in the shipped files (verify before release) |
| Libraries linked into `wget.exe` | not determinable from the shipped text files; a Windows Wget build typically links TLS, compression and other libraries with their own licenses (verify before release) |

Wget is used unmodified as an aggregate: it is not combined with GIMS code and GIMS is not a
derivative work of it. Because it is distributed in binary form under the GPL, the corresponding
source code for the exact version shipped must be available to recipients. Source releases of GNU
Wget are published at https://ftp.gnu.org/gnu/wget/ and the project page is
https://www.gnu.org/software/wget/. Determine the exact version and build provenance, and either
ship or offer in writing the matching source, before a public release (verify before release).

### 7-Zip

| | |
|---|---|
| Program | 7-Zip, `bin/7z/7z.exe` and `bin/7z/7z.dll` |
| Version | 26.01 per `readme.txt`; `History.txt` lists 26.02 as the newest entry, so the exact version needs confirming (verify before release) |
| Copyright | 7-Zip Copyright (C) 1999-2026 Igor Pavlov |
| Upstream | https://www.7-zip.org/ |

Licenses of the files, quoted from `bin/7z/License.txt`:

- `7z.dll`: GNU LGPL as the main license for most of the code; GNU LGPL with the unRAR license
  restriction for some code; BSD 3-clause for some code (LZFSE decompression, derived from Apple
  Inc.'s LZFSE library, copyright 2015-2016 Apple Inc.; ZSTD decompression, developed using
  Facebook Inc.'s decoder as reference, copyright Facebook, Inc.; both also copyright 2023-2026
  Igor Pavlov); BSD 2-clause for some code (XXH64, derived from Yann Collet's code, copyright
  2012-2021 Yann Collet and 2023-2026 Igor Pavlov).
- All other files: GNU LGPL. The LGPL text says version 2.1 or later.
- unRAR restriction: the RAR decompression code was developed using source code of the unRAR
  program, whose copyrights are owned by Alexander Roshal. The unRAR sources cannot be used to
  re-create the RAR compression algorithm, which is proprietary. Distribution of modified unRAR
  sources in separate form or as part of other software is permitted, provided that it is stated
  in the documentation and source comments that the code may not be used to develop a RAR
  (WinRAR) compatible archiver.
- Redistribution in binary form must reproduce the related license information from
  `License.txt`; that file ships in `bin/7z/`.

Source code of 7-Zip is available from https://www.7-zip.org/download.html. GIMS does not modify
7-Zip.

### lessmsi

| Item | Detail |
|---|---|
| Program | lessmsi, `bin/lessmsi/lessmsi.exe` (command line) and `lessmsi-gui.exe`, with its libraries |
| Use | `scripts/install-vba32.bat` unpacks the VBA32 `.msi` with it; nothing is installed on the system |
| License | MIT (project https://github.com/activescott/lessmsi); no license file is shipped in the folder (verify before release) |
| Bundled libraries | `libmspackn.dll` / `mspack.dll` (libmspack, LGPL-2.1) and `wix.dll` / `wixcab.dll` (WiX Toolset, MS-RL): confirm their terms and add the license texts to `bin/lessmsi/` (verify before release) |

lessmsi is used unmodified as a separate program, in the same way as Wget and 7-Zip above. The
language folders next to it are its own translations.

## 3. Example engines and downloaded software

The example engine definitions in `config/engines/` (`vba32.ini`, `rhash.ini`) and the install
scripts in `scripts/` are GIMS files and are proprietary. They contain no third-party code.

The programs they install are **not** part of this distribution. When a user runs *Download* or
*Update*, the scripts fetch VBA32 (the Windows Vista and later installer) from https://anti-virus.by/ and RHash from SourceForge
(https://sourceforge.net/projects/rhash/) onto the user's machine. Those programs are third-party
software under their own licenses and terms, which the user accepts from their vendors; GIMS
neither redistributes them nor grants any right to them. The same applies to any engine added by
the user.

## 4. Build-time and development tools not shipped

These are used to produce the executables and the icon PNGs and are not redistributed inside them,
apart from the PyInstaller bootloader and run-time files covered in section 1: PyInstaller itself
and `pyinstaller-hooks-contrib`, `pyinstaller-versionfile`, `altgraph`, `pefile`, `pywin32-ctypes`,
`setuptools` and `packaging`. The icon tooling (`tkinter-icons` 5.1.0 and
`tkinter-icons-fluent-reg` 1.1.0, both MIT, copyright Israel Dryer, and Pillow) runs only in
`tools/generate_icons.py` to render the Fluent glyphs into PNG files that are committed to the
repository; neither the tooling nor the Fluent font ships in the executables. Test and quality
tools (pytest, ruff, mypy) are development-only.
