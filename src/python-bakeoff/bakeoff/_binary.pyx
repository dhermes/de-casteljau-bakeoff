#!python
#cython: boundscheck=False, wraparound=False, language_level=3
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

"""Wrapper for ``libbakeoff.so``."""

import numpy as np
from numpy cimport ndarray as ndarray_t


cdef extern void BAKEOFF_do1(
    const int* num_nodes, const int* dimension, const double* nodes,
    const int* num_vals, const double* s_vals, double* evaluated)
cdef extern void BAKEOFF_do2(
    const int* num_nodes, const int* dimension, const double* nodes,
    const int* num_vals, const double* s_vals, double* evaluated)
cdef extern void BAKEOFF_do3(
    const int* num_nodes, const int* dimension, const double* nodes,
    const int* num_vals, const double* s_vals, double* evaluated)
cdef extern void BAKEOFF_forall1(
    const int* num_nodes, const int* dimension, const double* nodes,
    const int* num_vals, const double* s_vals, double* evaluated)
cdef extern void BAKEOFF_forall2(
    const int* num_nodes, const int* dimension, const double* nodes,
    const int* num_vals, const double* s_vals, double* evaluated)
cdef extern void BAKEOFF_forall3(
    const int* num_nodes, const int* dimension, const double* nodes,
    const int* num_vals, const double* s_vals, double* evaluated)
cdef extern void BAKEOFF_serial(
    const int* num_nodes, const int* dimension, const double* nodes,
    const int* num_vals, const double* s_vals, double* evaluated)
cdef extern void BAKEOFF_spread1(
    const int* num_nodes, const int* dimension, const double* nodes,
    const int* num_vals, const double* s_vals, double* evaluated)
cdef extern void BAKEOFF_spread2(
    const int* num_nodes, const int* dimension, const double* nodes,
    const int* num_vals, const double* s_vals, double* evaluated)
cdef extern void BAKEOFF_spread3(
    const int* num_nodes, const int* dimension, const double* nodes,
    const int* num_vals, const double* s_vals, double* evaluated)


def do1(double[::1, :] nodes, double[::1] s_vals):
    cdef int num_nodes, dimension, num_vals
    cdef ndarray_t[double, ndim=2, mode="fortran"] evaluated

    dimension, num_nodes = np.shape(nodes)
    num_vals, = np.shape(s_vals)
    evaluated = np.empty((dimension, num_vals), order="F")
    BAKEOFF_do1(
        &num_nodes,
        &dimension,
        &nodes[0, 0],
        &num_vals,
        &s_vals[0],
        &evaluated[0, 0],
    )
    return evaluated


def do2(double[::1, :] nodes, double[::1] s_vals):
    cdef int num_nodes, dimension, num_vals
    cdef ndarray_t[double, ndim=2, mode="fortran"] evaluated

    dimension, num_nodes = np.shape(nodes)
    num_vals, = np.shape(s_vals)
    evaluated = np.empty((dimension, num_vals), order="F")
    BAKEOFF_do2(
        &num_nodes,
        &dimension,
        &nodes[0, 0],
        &num_vals,
        &s_vals[0],
        &evaluated[0, 0],
    )
    return evaluated


def do3(double[::1, :] nodes, double[::1] s_vals):
    cdef int num_nodes, dimension, num_vals
    cdef ndarray_t[double, ndim=2, mode="fortran"] evaluated

    dimension, num_nodes = np.shape(nodes)
    num_vals, = np.shape(s_vals)
    evaluated = np.empty((dimension, num_vals), order="F")
    BAKEOFF_do3(
        &num_nodes,
        &dimension,
        &nodes[0, 0],
        &num_vals,
        &s_vals[0],
        &evaluated[0, 0],
    )
    return evaluated


def forall1(double[::1, :] nodes, double[::1] s_vals):
    cdef int num_nodes, dimension, num_vals
    cdef ndarray_t[double, ndim=2, mode="fortran"] evaluated

    dimension, num_nodes = np.shape(nodes)
    num_vals, = np.shape(s_vals)
    evaluated = np.empty((dimension, num_vals), order="F")
    BAKEOFF_forall1(
        &num_nodes,
        &dimension,
        &nodes[0, 0],
        &num_vals,
        &s_vals[0],
        &evaluated[0, 0],
    )
    return evaluated


def forall2(double[::1, :] nodes, double[::1] s_vals):
    cdef int num_nodes, dimension, num_vals
    cdef ndarray_t[double, ndim=2, mode="fortran"] evaluated

    dimension, num_nodes = np.shape(nodes)
    num_vals, = np.shape(s_vals)
    evaluated = np.empty((dimension, num_vals), order="F")
    BAKEOFF_forall2(
        &num_nodes,
        &dimension,
        &nodes[0, 0],
        &num_vals,
        &s_vals[0],
        &evaluated[0, 0],
    )
    return evaluated


def forall3(double[::1, :] nodes, double[::1] s_vals):
    cdef int num_nodes, dimension, num_vals
    cdef ndarray_t[double, ndim=2, mode="fortran"] evaluated

    dimension, num_nodes = np.shape(nodes)
    num_vals, = np.shape(s_vals)
    evaluated = np.empty((dimension, num_vals), order="F")
    BAKEOFF_forall3(
        &num_nodes,
        &dimension,
        &nodes[0, 0],
        &num_vals,
        &s_vals[0],
        &evaluated[0, 0],
    )
    return evaluated


def serial(double[::1, :] nodes, double[::1] s_vals):
    cdef int num_nodes, dimension, num_vals
    cdef ndarray_t[double, ndim=2, mode="fortran"] evaluated

    dimension, num_nodes = np.shape(nodes)
    num_vals, = np.shape(s_vals)
    evaluated = np.empty((dimension, num_vals), order="F")
    BAKEOFF_serial(
        &num_nodes,
        &dimension,
        &nodes[0, 0],
        &num_vals,
        &s_vals[0],
        &evaluated[0, 0],
    )
    return evaluated


def spread1(double[::1, :] nodes, double[::1] s_vals):
    cdef int num_nodes, dimension, num_vals
    cdef ndarray_t[double, ndim=2, mode="fortran"] evaluated

    dimension, num_nodes = np.shape(nodes)
    num_vals, = np.shape(s_vals)
    evaluated = np.empty((dimension, num_vals), order="F")
    BAKEOFF_spread1(
        &num_nodes,
        &dimension,
        &nodes[0, 0],
        &num_vals,
        &s_vals[0],
        &evaluated[0, 0],
    )
    return evaluated


def spread2(double[::1, :] nodes, double[::1] s_vals):
    cdef int num_nodes, dimension, num_vals
    cdef ndarray_t[double, ndim=2, mode="fortran"] evaluated

    dimension, num_nodes = np.shape(nodes)
    num_vals, = np.shape(s_vals)
    evaluated = np.empty((dimension, num_vals), order="F")
    BAKEOFF_spread2(
        &num_nodes,
        &dimension,
        &nodes[0, 0],
        &num_vals,
        &s_vals[0],
        &evaluated[0, 0],
    )
    return evaluated


def spread3(double[::1, :] nodes, double[::1] s_vals):
    cdef int num_nodes, dimension, num_vals
    cdef ndarray_t[double, ndim=2, mode="fortran"] evaluated

    dimension, num_nodes = np.shape(nodes)
    num_vals, = np.shape(s_vals)
    evaluated = np.empty((dimension, num_vals), order="F")
    BAKEOFF_spread3(
        &num_nodes,
        &dimension,
        &nodes[0, 0],
        &num_vals,
        &s_vals[0],
        &evaluated[0, 0],
    )
    return evaluated
