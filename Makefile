.PHONY: help
help:
	@echo 'Makefile for `de-casteljau-bakeoff` project'
	@echo ''
	@echo 'Usage:'
	@echo '   make hygiene       Use `emacs` to indent `.f90` files'
	@echo '   make shared        Create the `libbakeoff` shared library'
	@echo '   make shared-opt    Create the `libbakeoffopt` (optimized) shared library'
	@echo ''

.PHONY: hygiene
hygiene:
	git ls-files -- '*.f90' | \
	  xargs -I{} emacs \
	    --batch {} \
		--funcall mark-whole-buffer \
		--funcall f90-indent-subprogram \
		--funcall save-buffer

.PHONY: shared
shared:
	@echo 'TODO'

.PHONY: shared-opt
shared-opt:
	@echo 'TODO'
