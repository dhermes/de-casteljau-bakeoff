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
import bakeoff_opt


BAKEOFF_FUNCTIONS = (
    bakeoff.forall1,
    bakeoff.forall2,
    bakeoff.forall3,
    bakeoff.do1,
    bakeoff.do2,
    bakeoff.do3,
    bakeoff.spread1,
    bakeoff.spread2,
    bakeoff.spread3,
    bakeoff.serial,
    bakeoff.vs_algorithm64,
)
BAKEOFF_OPT_FUNCTIONS = (
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
    bakeoff_opt.vs_algorithm64,
)


def fn_name(fn):
    return f"{fn.__module__.replace('._binary', '')}.{fn.__qualname__}"


def verify_implementations(nodes, s_vals):
    points = bakeoff.serial(nodes, s_vals)
    fns = BAKEOFF_FUNCTIONS + BAKEOFF_OPT_FUNCTIONS

    equals = {}
    for fn in fns:
        key = fn_name(fn)
        points_also = fn(nodes, s_vals)
        if key in equals:
            raise KeyError(key)

        if np.all(points == points_also):
            equals[key] = "EQUAL"
        elif np.allclose(points, points_also):
            equals[key] = "ALLCLOSE"
        else:
            equals[key] = "DIFFERENT"

    return equals


def generate_nodes(num_nodes, num_values, seed):
    random_state = np.random.RandomState(seed=seed)
    x = sorted(random_state.randint(1000, size=num_nodes))
    y = sorted(random_state.randint(1000, size=num_nodes))
    nodes = np.asfortranarray([x, y], dtype=np.float64)

    s_vals = np.linspace(0.0, 1.0, num_values)

    return nodes, s_vals


def _compare_pair(name_timeit_result):
    _, timeit_result = name_timeit_result
    # Sort by average, break (very unlikely) ties with stdev.
    return timeit_result.average, timeit_result.stdev


def sort_results(timeit_results):
    """Sort results by average running time

    Assumes ``timeit_results`` contains pairs of the form.
    """
    return sorted(timeit_results, key=_compare_pair)
