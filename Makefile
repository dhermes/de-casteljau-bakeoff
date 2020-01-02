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

.PHONY: help
help:
	@echo 'Makefile for `de-casteljau-bakeoff` project'
	@echo ''
	@echo 'Usage:'
	@echo '   make hygiene       Use `emacs` to indent `.f90` files'
	@echo '   make shared        Create the `libbakeoff` shared library'
	@echo '   make shared-opt    Create the `libbakeoffopt` (optimized) shared library'
	@echo ''

################################################################################
# Variables and configuration
################################################################################
CURR_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD_DIR := $(CURR_DIR)/build
SRC_DIR := $(CURR_DIR)/src/fortran

FC := gfortran
F90 := .f90
OBJ := .o
BASE_FCFLAGS ?= -fPIC -Wall -Wextra -Wimplicit-interface -Werror -fmax-errors=1 -std=f2008 -J$(BUILD_DIR)
OPTIMIZED_FCFLAGS ?= -O3 -march=native -ffast-math -funroll-loops

# NOTE: **Must** specify the order for source files.
F90_SOURCES := \
	$(SRC_DIR)/types$(F90) \
	$(SRC_DIR)/forall_$(F90)
F90_OBJS := $(patsubst $(SRC_DIR)/%$(F90), $(BUILD_DIR)/%$(OBJ), $(F90_SOURCES))

################################################################################
# Targets
################################################################################

.PHONY: hygiene
hygiene:
	git ls-files -- '*.f90' | \
	  xargs -I{} emacs \
	    --batch {} \
		--funcall mark-whole-buffer \
		--funcall f90-indent-subprogram \
		--funcall save-buffer

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%$(OBJ): $(SRC_DIR)/%$(F90) $(BUILD_DIR)
	$(FC) $(BASE_FCFLAGS) $(OPTIMIZED_FCFLAGS) -c $< -o $@

.PHONY: shared
shared: $(F90_OBJS)
	cd src/python-bakeoff/ && \
	  ../../.venv/bin/python setup.py build_ext --inplace

.PHONY: shared-opt
shared-opt: $(F90_OBJS)
	@echo 'TODO'

src/python-bakeoff/bakeoff/_binary.c: src/python-bakeoff/bakeoff/_binary.pyx
	.venv/bin/cython src/python-bakeoff/bakeoff/_binary.pyx
