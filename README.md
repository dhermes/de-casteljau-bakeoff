# de Casteljau Bakeoff

> Experimenting with competing implementations for simultaneous
> B&#XE9;zier Curve evaluation

## Overview

```
$ make
Makefile for `de-casteljau-bakeoff` project

Usage:
   make venv                               Create Python virtual environment
   make run-jupyter                        Run Jupyter notebook(s)
   make update-requirements                Update Python requirements
   make hygiene                            Autoformat `.f90` and `.py` files and verify "copied" files
   make shared [OPTIMIZED=true]            Build `bakeoff(_opt)` Python package that wraps Fortran implementations
   make install-shared [OPTIMIZED=true]    Install `bakeoff(_opt)` Python package into virtual environment
   make verify-shared [OPTIMIZED=true]     Verify the `bakeoff(_opt)` Python package
   make clean                              Delete all generated files

```

## Run Notebook Server

```
make venv
make install-shared
make install-shared OPTIMIZED=true
make run-jupyter
```

## Hygiene

To [indent][1] the `.f90` files consistently:

```
make hygiene
```

This uses:

```
emacs \
  --batch filename.f90 \
  --funcall mark-whole-buffer \
  --funcall f90-indent-subprogram \
  --funcall save-buffer
```

[1]: https://www.fortran90.org/src/faq.html#how-do-i-indent-free-form-fortran-source-code-in-a-consistent-manner-automatically
