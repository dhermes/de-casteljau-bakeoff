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
