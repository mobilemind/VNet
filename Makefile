#!/usr/bin/make -f

##
# FYI VNet gh-pages
#
# directories/paths
WEB := web
# files
MANIFESTS := vnet.manifest vnetp.manifest
HTMLFILES := vnet.html vnetp.html
# macros/utils
CHANGEDFILES = `git diff --name-only`

default: $(HTMLFILES) $(MANIFESTS) | IMG
	@echo 'make: Updated gh-pages root files'

%.html: $(WEB)/$(*F)
	@echo '    $@'
	@cp -fp $(WEB)/$(*F) $@.gz && gunzip -f $@.gz

%.manifest: $(WEB)/%.manifest
	@cp -fpv $(WEB)/$@ .

.PHONY: IMG
IMG: 
	@echo '    Copying images...' && cp -Rfp $(WEB)/img .

.PHONY: deploy
deploy: default
	@echo '    Checking "git diff --name-only" to trigger "git push gh-pages"'
	@[[ -n "$CHANGEDFILES" ]] && (\
		for AFILE in $(CHANGEDFILES); do git add $$AFILE; done; \
		git commit -m 'revised HTML'; git push ) \
	|| true

.PHONY: clean
clean:
	rm -f $(HTMLFILES) $(MANIFESTS)
