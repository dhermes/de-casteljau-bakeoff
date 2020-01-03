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
	@echo '   make hygiene                           Use `emacs` to indent `.f90` files'
	@echo '   make shared [OPTIMIZED=true]           Create `bakeoff` Python package that wraps Fortran implementations'
	@echo '   make verify-shared [OPTIMIZED=true]    Verify the `bakeoff` Python package'
	@echo '   make clean                             Delete all generated files'
	@echo ''

################################################################################
# Variables and configuration
################################################################################
CURR_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
SRC_DIR := $(CURR_DIR)/src/fortran

FC := gfortran
F90 := .f90
OBJ := .o
C_PREPROCESSOR := -cpp
BASE_FCFLAGS ?= -fPIC -Wall -Wextra -Wimplicit-interface -Werror -fmax-errors=1 -std=f2008
OPTIMIZED_FCFLAGS ?= -O3 -march=native -ffast-math -funroll-loops
ifdef OPTIMIZED
BUILD_DIR := $(CURR_DIR)/build_opt
FCFLAGS := $(BASE_FCFLAGS) -J$(BUILD_DIR) $(OPTIMIZED_FCFLAGS)
DOPT := _OPT
CYTHON_FILE := src/python-bakeoff-opt/bakeoff_opt/_binary.c
PYTHON_DIR := src/python-bakeoff-opt
else
BUILD_DIR := $(CURR_DIR)/build
FCFLAGS := $(BASE_FCFLAGS) -J$(BUILD_DIR)
DOPT :=
CYTHON_FILE := src/python-bakeoff/bakeoff/_binary.c
PYTHON_DIR := src/python-bakeoff
endif

# NOTE: **Must** specify the order for source files.
F90_SOURCES := \
	$(SRC_DIR)/types$(F90) \
	$(SRC_DIR)/forall_$(F90) \
	$(SRC_DIR)/do_$(F90) \
	$(SRC_DIR)/spread_$(F90) \
	$(SRC_DIR)/serial_$(F90)
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
	$(FC) $(C_PREPROCESSOR) -DOPT=$(DOPT) $(FCFLAGS) -c $< -o $@

src/python-bakeoff/bakeoff/_binary.c: src/python-bakeoff/bakeoff/_binary.pyx
	.venv/bin/cython src/python-bakeoff/bakeoff/_binary.pyx

src/python-bakeoff-opt/bakeoff_opt/_binary.c: src/python-bakeoff-opt/bakeoff_opt/_binary.pyx
	.venv/bin/cython src/python-bakeoff-opt/bakeoff_opt/_binary.pyx

.PHONY: shared
shared: $(F90_OBJS) $(CYTHON_FILE)
	cd $(PYTHON_DIR) && \
	  ../../.venv/bin/python setup.py build_ext --inplace

.PHONY: verify-shared
verify-shared: $(PYTHON_DIR)/verify.py shared
	cd $(PYTHON_DIR)/ && \
	  ../../.venv/bin/python verify.py

.PHONY: clean
clean:
	rm -fr \
	  build/ \
	  build_opt/ \
	  src/python-bakeoff-opt/bakeoff_opt/__pycache__/ \
	  src/python-bakeoff-opt/build/ \
	  src/python-bakeoff/bakeoff/__pycache__/ \
	  src/python-bakeoff/build/
	rm -f \
	  src/fortran/*.f90~ \
	  src/python-bakeoff/bakeoff/_binary.*.so \
	  src/python-bakeoff-opt/bakeoff_opt/_binary.*.so
