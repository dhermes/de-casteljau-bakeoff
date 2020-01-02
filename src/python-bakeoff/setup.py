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

"""Wrapper for ``libbakeoff.so``.

$ python setup.py build_ext --inplace
"""


import os

import numpy as np
import setuptools


HERE = os.path.dirname(os.path.abspath(__file__))
# NOTE: This is a **massive** shortcut and should not be done. This assumes
#       that ``setup.py`` will be in the right place relative to the
#       **already built** object files.
EXTRA_OBJECTS = (
    os.path.join(HERE, "..", "..", "build", "types.o"),
    os.path.join(HERE, "..", "..", "build", "forall_.o"),
    os.path.join(HERE, "..", "..", "build", "do_.o"),
)


def extension_modules():
    missing = [path for path in EXTRA_OBJECTS if not os.path.isfile(path)]
    if missing:
        raise RuntimeError("Missing object file(s)", missing)

    extension = setuptools.Extension(
        "bakeoff._binary",
        [os.path.join("bakeoff", "_binary.c")],
        extra_objects=EXTRA_OBJECTS,
        include_dirs=[np.get_include()],
    )
    return [extension]


def main():
    ext_modules = extension_modules()
    setuptools.setup(
        name="bakeoff",
        packages=["bakeoff"],
        install_requires=["numpy"],
        ext_modules=ext_modules,
    )


if __name__ == "__main__":
    main()
