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
SRCDIR := src
BUILDDIR := build
COMMONLIB := $$HOME/common/lib
WEBDIR := web
IMGDIR := img
VERSIONTXT := $(SRCDIR)/VERSION.txt
VPATH := $(WEBDIR):$(BUILDDIR)
# macros/utils
HTMLCOMPRESSOR := java -jar $(COMMONLIB)/htmlcompressor-1.5.2.jar
COMPRESSOPTIONS := -t html -c utf-8 --remove-quotes --remove-intertag-spaces --remove-surrounding-spaces min --compress-js --compress-css
MMBUILDDATE := _MmBUILDDATE_
BUILDDATE := $(shell date)
MMVERSION := _MmVERSION_
VERSION := $(shell head -1 $(VERSIONTXT))
GROWL := $(shell ! hash growlnotify &>/dev/null && echo 'true' || ([[ 'darwin11' == $$OSTYPE ]] && echo "growlnotify -t $(PROJ) -m" || ([[ 'cygwin' == $$OSTYPE ]] && echo -e "growlnotify /t:$(PROJ)\c" || echo)) )
REPLACETOKENS = perl -p -i -e "s/$(MMVERSION)/$(VERSION)/g;" $@; \perl -p -i -e "s/$(MMBUILDDATE)/$(BUILDDATE)/g;" $@


default: $(PROJECTS) | $(BUILDDIR) $(WEBDIR) $(IMGDIR)
	@(chmod -R 744 $(WEBDIR); \
		$(GROWL) "Done. See $(PROJ)/$(WEBDIR) directory."; echo; \
		echo "Done. See $(PROJ)/$(WEBDIR) directory"; echo )

$(PROJ)  $(SUBPROJ): $(MANIFESTS) $(COMPRESSEDFILES) | $(WEBDIR)
	@(echo; \
		echo "Copying built files…"; \
		cp -f $(BUILDDIR)/$@.html.gz $(WEBDIR)/$@; \
		cp -f $(BUILDDIR)/$@.manifest $(WEBDIR); \
		cp -Rfp $(SRCDIR)/$(IMGDIR) $(WEBDIR) )

# run through html compressor and into gzip
%.html.gz: %.html | $(BUILDDIR)
	@(echo "Compressing $^…"; \
		$(HTMLCOMPRESSOR) $(COMPRESSOPTIONS) $(BUILDDIR)/$^ | gzip > $(BUILDDIR)/$@ )

# copy HTML to $(BUILDDIR) and replace tokens, then check with tidy & jsl (JavaScript Lint)
%.html: $(SRCDIR)/%.html $(VERSIONTXT) | $(BUILDDIR)
	@(echo; echo $@; \
		cp -f src/$@ $(BUILDDIR); \
		cd $(BUILDDIR); \
		$(REPLACETOKENS); \
		hash tidy && (tidy -eq $@; [[ $$? -lt 2 ]] && true); \
		hash jsl && jsl -process $@ -nologo -nofilelisting -nosummary )

# copy manifest to $(BUILDDIR) and replace tokens
%.manifest: $(SRCDIR)/%.manifest $(VERSIONTXT) | $(BUILDDIR)
	@(echo; echo $@; \
		cp -f src/$@ $(BUILDDIR); \
		cd $(BUILDDIR); \
		$(REPLACETOKENS) )

.PHONY: $(BUILDDIR)
$(BUILDDIR):
	@[[ -d $(BUILDDIR) ]] || mkdir -m 744 $(BUILDDIR)

.PHONY: $(WEBDIR)
$(WEBDIR):
	@[[ -d $(WEBDIR) ]] || mkdir -m 744 $(WEBDIR)

.PHONY: $(IMGDIR)
$(IMGDIR): | $(BUILDDIR)
	@cp -Rfp $(SRCDIR)/$(IMGDIR) $(BUILDDIR)

.PHONY: clean
clean:
	@echo 'Cleaning build directory and web directory…'
	@rm -rf $(BUILDDIR)/* $(WEBDIR)/* || true
