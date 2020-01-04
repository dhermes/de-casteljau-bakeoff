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

import collections

import matplotlib
import matplotlib.pyplot as plt
import mpl_toolkits.mplot3d
import numpy as np

import nb_helpers


def plot_3d(log_N_vals, log_k_vals, log_timeit_vals, fn_name):
    fig = plt.figure()
    ax = fig.gca(projection="3d")

    ax.plot_trisurf(
        log_N_vals[fn_name],
        log_k_vals[fn_name],
        log_timeit_vals[fn_name],
        linewidth=0.2,
        antialiased=True,
    )

    ax.set_xlabel(r"$\log_2 N$")
    ax.set_ylabel(r"$\log_2 k$")
    ax.set_zlabel(r"$\log_2 T$")
    ax.set_title(fn_name)

    plt.show()


def main():
    matplotlib.rc("mathtext", fontset="cm", rm="serif")

    results_cache = nb_helpers.get_timeit_results()
    log_N_vals = collections.defaultdict(list)
    log_k_vals = collections.defaultdict(list)
    log_timeit_vals = collections.defaultdict(list)

    for key, timeit_result in results_cache.items():
        fn_name, num_nodes, num_values, _ = key
        log_N_vals[fn_name].append(np.log2(num_nodes))
        log_k_vals[fn_name].append(np.log2(num_values))
        log_timeit_vals[fn_name].append(np.log2(timeit_result.average))

    selected_functions = (
        "bakeoff_opt.forall1",
        "bakeoff_opt.serial",
        "bakeoff_opt.spread1",
        "bakeoff_opt.vs_algorithm64",
    )
    for fn_name in selected_functions:
        plot_3d(log_N_vals, log_k_vals, log_timeit_vals, fn_name)


if __name__ == "__main__":
    main()
