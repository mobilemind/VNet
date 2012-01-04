#!/usr/bin/make -f

##
# VNET PROJECT
##
PROJ = vnet
SUBPROJ = vnetp
# directories/paths
SRCDIR := src
BUILDDIR := build
COMMONLIB := $$HOME/common/lib
WEBDIR := web
IMGDIR := img
VPATH := $(WEBDIR):$(BUILDDIR)
# files
PROJECTS = $(PROJ) $(SUBPROJ)
COMPRESSEDFILES = $(PROJ).html.gz $(SUBPROJ).html.gz
MANIFESTS = $(PROJ).manifest $(SUBPROJ).manifest
VERSIONTXT := $(SRCDIR)/VERSION.txt
# macros/utils
MMBUILDDATE := _MmBUILDDATE_
BUILDDATE := $(shell date)
MMVERSION := _MmVERSION_
VERSION := $(shell head -1 $(VERSIONTXT))
HTMLCOMPRESSOR := htmlcompressor-1.5.2.jar
HTMLCOMPRESSORPATH := $(shell [[ 'cygwin' == $$OSTYPE ]] &&  echo "`cygpath -w $(COMMONLIB)`\\" || echo "$(COMMONLIB)/")
HTMLCOMPRESSOR := java -jar "$(HTMLCOMPRESSORPATH)$(HTMLCOMPRESSOR)"
COMPRESSOPTIONS := -t html -c utf-8 --remove-quotes --remove-intertag-spaces --remove-surrounding-spaces min --compress-js --compress-css
GROWL := $(shell ! hash growlnotify &>/dev/null && echo 'true' || ([[ 'darwin11' == $$OSTYPE ]] && echo "growlnotify -t $(PROJ) -m" || ([[ 'cygwin' == $$OSTYPE ]] && echo -e "growlnotify /t:$(PROJ)\c" || echo)) )
REPLACETOKENS = perl -p -i -e 's/$(MMVERSION)/$(VERSION)/g;' $@; perl -p -i -e 's/$(MMBUILDDATE)/$(BUILDDATE)/g;' $@


default: $(PROJECTS) | $(BUILDDIR) $(WEBDIR) $(IMGDIR)
	@(chmod -R 744 $(WEBDIR); \
		$(GROWL) "Done. See $(PROJ)/$(WEBDIR) directory."; echo; \
		echo "Done. See $(PROJ)/$(WEBDIR) directory"; echo )

$(PROJ)  $(SUBPROJ): $(MANIFESTS) $(COMPRESSEDFILES) | $(WEBDIR)
	@(echo; \
		echo "Copying built files..."; \
		cp -fp $(BUILDDIR)/$@.html.gz $(WEBDIR)/$@; \
		cp -fp $(BUILDDIR)/$@.manifest $(WEBDIR); \
		cp -Rfp $(SRCDIR)/$(IMGDIR) $(WEBDIR) )

# run through html compressor and into gzip
%.html.gz: %.html | $(BUILDDIR)
	@(echo "Compressing $^..."; \
		$(HTMLCOMPRESSOR) $(COMPRESSOPTIONS) $(BUILDDIR)/$^ | gzip -f9 > $(BUILDDIR)/$@ )

# copy HTML to $(BUILDDIR) and replace tokens, then check with tidy & jsl (JavaScript Lint)
%.html: $(SRCDIR)/%.html $(VERSIONTXT) | $(BUILDDIR)
	@(echo; echo $@; \
		cp -f $(SRCDIR)/$@ $(BUILDDIR); \
		cd $(BUILDDIR); \
		$(REPLACETOKENS); \
		hash tidy && (tidy -eq $@; [[ $$? -lt 2 ]] && true); \
		hash jsl && jsl -process $@ -nologo -nofilelisting -nosummary )

# copy manifest to $(BUILDDIR) and replace tokens
%.manifest: $(SRCDIR)/%.manifest $(VERSIONTXT) | $(BUILDDIR)
	@(echo; echo $@; \
		cp -fp $(SRCDIR)/$@ $(BUILDDIR); \
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
	@echo 'Cleaning build directory and web directory...'
	@rm -rf $(BUILDDIR)/* $(WEBDIR)/* || true
