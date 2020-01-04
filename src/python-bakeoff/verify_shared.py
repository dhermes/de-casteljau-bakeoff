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


def from_serial_inner(bakeoff_module):
    def serial_inner(nodes, s_vals):
        dimension, _ = nodes.shape
        (num_vals,) = s_vals.shape
        evaluated = np.empty((dimension, num_vals), order="F")
        for j in range(num_vals):
            evaluated[:, j] = bakeoff_module.serial_inner(nodes, s_vals[j])

        return evaluated

    return serial_inner


def do_verify(bakeoff_module):
    print(f"Verifying: {bakeoff_module}")
    functions = (
        bakeoff_module.forall1,
        bakeoff_module.forall2,
        bakeoff_module.forall3,
        bakeoff_module.do1,
        bakeoff_module.do2,
        bakeoff_module.do3,
        bakeoff_module.spread1,
        bakeoff_module.spread2,
        bakeoff_module.spread3,
        bakeoff_module.serial,
        from_serial_inner(bakeoff_module),
        bakeoff_module.vs_algorithm32,
        bakeoff_module.vs_algorithm53,
        bakeoff_module.vs_algorithm64,
    )
    nodes = np.asfortranarray([[1.0, 1.0, 2.0, 2.0], [0.0, 1.0, 0.0, 1.0]])
    s_vals = np.asfortranarray([0.0, 0.5, 1.0])
    expected = np.asfortranarray([[1.0, 1.5, 2.0], [0.0, 0.5, 1.0]])
    for fn in functions:
        evaluated = fn(nodes, s_vals)
        assert np.all(evaluated == expected)
        print(f"Verified: {fn.__name__}")
