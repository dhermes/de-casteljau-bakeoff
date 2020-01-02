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

import numpy as np

import bakeoff


def main():
    fns = (
        bakeoff.forall1,
        bakeoff.forall2,
        bakeoff.forall3,
        bakeoff.do1,
        bakeoff.do2,
        bakeoff.do3,
    )
    nodes = np.asfortranarray([[1.0, 1.0, 2.0, 2.0], [0.0, 1.0, 0.0, 1.0]])
    s_vals = np.asfortranarray([0.0, 0.5, 1.0])
    expected = np.asfortranarray([[1.0, 1.5, 2.0], [0.0, 0.5, 1.0]])
    for fn in fns:
        evaluated = fn(nodes, s_vals)
        assert np.all(evaluated == expected)
        print(f"Verified: {fn.__name__}")


if __name__ == "__main__":
    main()
