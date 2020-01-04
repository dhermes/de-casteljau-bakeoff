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

import pathlib
import pickle

import bakeoff
import bakeoff_opt
import matplotlib.pyplot as plt
import numpy as np


HERE = pathlib.Path(__file__).resolve().parent
STORED_RESULTS = HERE / "timeit_results.pkl"
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
    bakeoff.vs_algorithm32,
    bakeoff.vs_algorithm53,
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
    bakeoff_opt.vs_algorithm32,
    bakeoff_opt.vs_algorithm53,
    bakeoff_opt.vs_algorithm64,
)


def fn_name(fn):
    return f"{fn.__module__.replace('._binary', '')}.{fn.__qualname__}"


def verify_implementations(nodes, s_vals, substring_match=None):
    points = bakeoff.serial(nodes, s_vals)
    functions = BAKEOFF_FUNCTIONS + BAKEOFF_OPT_FUNCTIONS

    equals = {}
    for fn in functions:
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

    if substring_match is None:
        return equals

    return {
        key: value for key, value in equals.items() if substring_match in key
    }


def generate_nodes(num_nodes, num_values, seed):
    # TODO: Cache outputs?
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


def get_timeit_results():
    # Load previous results from disk.
    # NOTE: This is a bad idea if these benchmarks are being
    #       run on multiple machines.
    if not STORED_RESULTS.is_file():
        return {}

    with open(STORED_RESULTS, "rb") as file_obj:
        return pickle.load(file_obj)


def store_timeit_results(results_cache):
    with open(STORED_RESULTS, "wb") as file_obj:
        pickle.dump(results_cache, file_obj)


def timeit(get_ipython, fn, *args, **kwargs):
    """Invoke the IPython timeit line magic.

    Determined how this worked via:

    >>> import dis
    >>>
    >>> def capture_line_magic(fn):
    ...     timeit_result = %timeit -o -q fn()
    ...     return timeit_result
    ...
    >>> dis.dis(capture_line_magic)
    """
    timeit_result = get_ipython().run_line_magic(
        "timeit", "-o -q fn(*args, **kwargs)"
    )
    return timeit_result


def time_function(get_ipython, results_cache, fn, num_nodes, num_values, seed):
    key = (fn_name(fn), num_nodes, num_values, seed)
    if key not in results_cache:
        nodes, s_vals = generate_nodes(num_nodes, num_values, seed)
        results_cache[key] = timeit(get_ipython, fn, nodes, s_vals)

    return results_cache[key]


def new_axis():
    figure = plt.figure(figsize=(18, 12), dpi=80)
    return figure.gca()


def plot_data_nodes(
    get_ipython, results_cache, functions, num_nodes_list, num_values, seed
):
    ax = new_axis()

    for fn in functions:
        x_vals = []
        y_vals = []
        y_below = []
        y_above = []
        for num_nodes in num_nodes_list:
            timeit_result = time_function(
                get_ipython, results_cache, fn, num_nodes, num_values, seed
            )
            # 2 std deviations ~= 95%
            below = timeit_result.average - 2.0 * timeit_result.stdev
            above = timeit_result.average + 2.0 * timeit_result.stdev
            # If the running time goes non-positive, ignore the datapoint
            if below <= 0.0:
                continue

            x_vals.append(num_nodes)
            y_vals.append(timeit_result.average)
            y_below.append(below)
            y_above.append(above)

        (line,) = ax.loglog(x_vals, y_vals, marker="o", label=fn.__name__)
        ax.fill_between(
            x_vals, y_below, y_above, alpha=0.5, color=line.get_color()
        )

    ax.set_xscale("log", basex=2)
    ax.set_yscale("log", basey=2)
    ax.set_title(f"Number of Input Values: {num_values}")
    ax.set_xlabel("Number of Nodes")
    ax.set_ylabel("Average Evaluation Time (s)")
    ax.axis("scaled")
    ax.legend()


def _compare_times(
    get_ipython, results_cache, functions, num_nodes, num_values, seed
):
    timeit_results = []
    for fn in functions:
        name = fn.__name__
        timeit_result = time_function(
            get_ipython, results_cache, fn, num_nodes, num_values, seed
        )
        timeit_results.append((name, timeit_result))

    timeit_results = sort_results(timeit_results)
    max_width = max(len(name) for name, _ in timeit_results)

    for name, timeit_result in timeit_results:
        print(f"{name:{max_width}}: {timeit_result}")


def compare_bakeoff_times(
    get_ipython, results_cache, num_nodes, num_values, seed
):
    print("Non-Optimized Implementations")
    print("-----------------------------")
    _compare_times(
        get_ipython,
        results_cache,
        BAKEOFF_FUNCTIONS,
        num_nodes,
        num_values,
        seed,
    )

    print("")

    print("Optimized Implementations")
    print("-------------------------")
    _compare_times(
        get_ipython,
        results_cache,
        BAKEOFF_OPT_FUNCTIONS,
        num_nodes,
        num_values,
        seed,
    )


def plot_data_values(
    get_ipython, results_cache, functions, num_nodes, num_values_list, seed
):
    ax = new_axis()

    for fn in functions:
        x_vals = []
        y_vals = []
        y_below = []
        y_above = []
        for num_values in num_values_list:
            timeit_result = time_function(
                get_ipython, results_cache, fn, num_nodes, num_values, seed
            )
            # 2 std deviations ~= 95%
            below = timeit_result.average - 2.0 * timeit_result.stdev
            above = timeit_result.average + 2.0 * timeit_result.stdev
            # If the running time goes non-positive, ignore the datapoint
            if below <= 0.0:
                continue

            x_vals.append(num_values)
            y_vals.append(timeit_result.average)
            y_below.append(below)
            y_above.append(above)

        (line,) = ax.loglog(x_vals, y_vals, marker="o", label=fn.__name__)
        ax.fill_between(
            x_vals, y_below, y_above, alpha=0.5, color=line.get_color()
        )

    ax.set_xscale("log", basex=2)
    ax.set_yscale("log", basey=2)
    ax.set_title(f"Number of Nodes: {num_nodes}")
    ax.set_xlabel("Number of Input Values")
    ax.set_ylabel("Average Evaluation Time (s)")
    ax.axis("scaled")
    ax.legend()
