# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# NOTE: This file is copied (rather than symlinked) since a symlink **outside**
#       of the package tree won't get copied during a ``pip install``.

import os
import pathlib
import subprocess
import sys

import numpy as np
import setuptools


FORTRAN_LIBRARY_PREFIX = "libraries: ="
GFORTRAN_MISSING_LIBS = """\
``gfortran`` default library path not found via:

$ gfortran -print-search-dirs
{}"""
GFORTRAN_BAD_PATH = "``gfortran`` library path {} is not a directory."


def gfortran_search_path():
    """Get the library directory paths for ``gfortran``.

    Looks for ``libraries: =`` in the output of ``gfortran -print-search-dirs``
    and then parses the paths. If this fails for any reason, this method will
    print an error and return ``library_dirs``.

    Returns:
        List[str]: The library directories for ``gfortran``.
    """
    cmd = ("gfortran", "-print-search-dirs")
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    return_code = process.wait()
    # Bail out if the command failed.
    if return_code != 0:
        return []

    cmd_output = process.stdout.read().decode("utf-8")
    # Find single line starting with ``libraries: ``.
    search_lines = cmd_output.strip().split("\n")
    library_lines = [
        line[len(FORTRAN_LIBRARY_PREFIX) :]
        for line in search_lines
        if line.startswith(FORTRAN_LIBRARY_PREFIX)
    ]
    if len(library_lines) != 1:
        msg = GFORTRAN_MISSING_LIBS.format(cmd_output)
        print(msg, file=sys.stderr)
        return []

    # Go through each library in the ``libraries: = ...`` line.
    library_line = library_lines[0]
    accepted = set()
    for part in library_line.split(os.pathsep):
        full_path = os.path.abspath(part.strip())
        if os.path.isdir(full_path):
            accepted.add(full_path)
        else:
            # Ignore anything that isn't a directory.
            msg = GFORTRAN_BAD_PATH.format(full_path)
            print(msg, file=sys.stderr)

    return sorted(accepted)


def get_extra_objects(here):
    return (
        os.path.join(here, "object_files", "types.o"),
        os.path.join(here, "object_files", "forall_.o"),
        os.path.join(here, "object_files", "do_.o"),
        os.path.join(here, "object_files", "spread_.o"),
        os.path.join(here, "object_files", "serial_.o"),
    )


def extension_modules(here, name):
    extra_objects = get_extra_objects(here)
    missing = [path for path in extra_objects if not os.path.isfile(path)]
    if missing:
        parts = ["Missing object file(s):"]
        parts.extend(f"- {path}" for path in missing)
        parts.extend(
            [
                "",
                f"here: {here}",
                f"__file__: {__file__}",
                "",
                "files in `here`:",
            ]
        )
        files_here = pathlib.Path(here).glob("*")
        parts.extend(f"- {path}" for path in files_here)

        msg = "\n".join(parts)
        raise RuntimeError(msg)

    extension = setuptools.Extension(
        f"{name}._binary",
        [os.path.join(name, "_binary.c")],
        extra_objects=extra_objects,
        include_dirs=[np.get_include()],
        libraries=["gfortran"],
        library_dirs=gfortran_search_path(),
    )
    return [extension]


def do_setup(here, name):
    ext_modules = extension_modules(here, name)
    setuptools.setup(
        name=name,
        packages=[name],
        install_requires=["numpy"],
        ext_modules=ext_modules,
    )
