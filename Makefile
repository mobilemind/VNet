#!/usr/bin/make -f

##
# VNET PROJECT
##
PROJ = vnet
SUBPROJ = vnetp
PROJECTS = $(PROJ) $(SUBPROJ)
COMPRESSEDFILES = $(PROJ).html.gz $(SUBPROJ).html.gz
MANIFESTS = $(PROJ).manifest $(SUBPROJ).manifest
# directories/paths
SRC := src
BUILD := build
COMMONLIB := $$HOME/common/lib
WEB := web
IMGDIR := img
VERSIONTXT := $(SRC)/VERSION.txt
VPATH := $(WEB):$(BUILD)
# macros/utils
HTMLCOMPRESSOR := java -jar $(COMMONLIB)/htmlcompressor-1.5.2.jar
COMPRESSOPTIONS := -t html -c utf-8 --remove-quotes --remove-intertag-spaces --remove-surrounding-spaces min --compress-js --compress-css
BUILDDATE := $(shell date)
VERSION := $(shell head -1 $(VERSIONTXT))
GROWL := $(shell ! hash growlnotify &>/dev/null && echo 'true' || ([[ 'darwin11' == $$OSTYPE ]] && echo "growlnotify -t $(PROJ) -m" || ([[ 'cygwin' == $$OSTYPE ]] && echo -e "growlnotify /t:$(PROJ)\c" || echo)) )
REPLACETOKENS = perl -p -i -e "s/\@VERSION\@/$(VERSION)/g;" $@; perl -p -i -e "s/\@BUILDDATE\@/$(BUILDDATE)/g;" $@


default: $(PROJECTS) | $(BUILD) $(WEB) $(IMGDIR)
	@(chmod -R 744 $(WEB); \
		$(GROWL) "Done. See $(PROJ)/$(WEB) directory."; echo; \
		echo "Done. See $(PROJ)/$(WEB) directory"; echo )

$(PROJ)  $(SUBPROJ): $(MANIFESTS) $(COMPRESSEDFILES) | $(WEB)
	@(echo; \
		echo "Copying built files…"; \
		cp -f $(BUILD)/$@.html.gz $(WEB)/$@; \
		cp -f $(BUILD)/$@.manifest $(WEB); \
		cp -Rfp $(SRC)/$(IMGDIR) $(WEB) )

# run through html compressor and into gzip
%.html.gz: %.html | $(BUILD)
	@(echo "Compressing $^…"; \
		$(HTMLCOMPRESSOR) $(COMPRESSOPTIONS) $(BUILD)/$^ | gzip > $(BUILD)/$@ )

# copy HTML to $(BUILD) and replace tokens, then check with tidy & jsl (JavaScript Lint)
%.html: $(SRC)/%.html $(VERSIONTXT) | $(BUILD)
	@(echo; echo $@; \
		cp -f src/$@ $(BUILD); \
		cd $(BUILD); \
		$(REPLACETOKENS); \
		hash tidy && (tidy -eq $@; [[ $$? -lt 2 ]] && true); \
		hash jsl && jsl -process $@ -nologo -nofilelisting -nosummary )

# copy manifest to $(BUILD) and replace tokens
%.manifest: $(SRC)/%.manifest $(VERSIONTXT) | $(BUILD)
	@(echo; echo $@; \
		cp -f src/$@ $(BUILD); \
		cd $(BUILD); \
		$(REPLACETOKENS) )

.PHONY: $(BUILD)
$(BUILD):
	@[[ -d $(BUILD) ]] || mkdir -m 744 $(BUILD)

.PHONY: $(WEB)
$(WEB):
	@[[ -d $(WEB) ]] || mkdir -m 744 $(WEB)

.PHONY: $(IMGDIR)
$(IMGDIR): | $(BUILD)
	@cp -Rfp $(SRC)/$(IMGDIR) $(BUILD)

.PHONY: clean
clean:
	@echo 'Cleaning build directory and web directory…'
	@rm -rf $(BUILD)/* $(WEB)/* || true
