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

import bakeoff_opt


def main():
    fns = (
        bakeoff_opt.forall1,
        bakeoff_opt.forall2,
        bakeoff_opt.forall3,
        bakeoff_opt.do1,
        bakeoff_opt.do2,
        bakeoff_opt.do3,
        bakeoff_opt.spread1,
        bakeoff_opt.spread2,
        bakeoff_opt.spread3,
        bakeoff_opt.serial,
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
