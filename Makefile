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
HTMLCOMPRESSORJAR := htmlcompressor-1.5.2.jar
HTMLCOMPRESSORPATH := $(shell [[ 'cygwin' == $$OSTYPE ]] &&  echo "`cygpath -w $(COMMONLIB)`\\" || echo "$(COMMONLIB)/")
HTMLCOMPRESSOR := java -jar '$(HTMLCOMPRESSORPATH)$(HTMLCOMPRESSORJAR)'
COMPRESSOPTIONS := -t html -c utf-8 --remove-quotes --remove-intertag-spaces --remove-surrounding-spaces min --compress-js --compress-css
GRECHO = $(shell hash grecho &> /dev/null && echo 'grecho' || echo 'printf')
REPLACETOKENS = perl -p -i -e 's/$(MMVERSION)/$(VERSION)/g;' $@; perl -p -i -e 's/$(MMBUILDDATE)/$(BUILDDATE)/g;' $@


default: $(PROJECTS) | $(BUILDDIR) $(WEBDIR) $(IMGDIR)
	@(chmod -R 755 $(WEBDIR); $(GRECHO) 'make:' "Done. See $(PROJ)/$(WEBDIR) directory.\n" )

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

# deploy
.PHONY: deploy
deploy: default
	@echo "Deploy to: $$MYSERVER/me"
	@(cd $(WEBDIR); \
		scp -p vnet vnetp *.manifest "$$MYUSER@$$MYSERVER:$$MYSERVERHOME/me"; \
		scp -p img/*.* "$$MYUSER@$$MYSERVER:$$MYSERVERHOME/me/img"; \
		echo \
	)
	@$(GRECHO) 'make:' "Done. Deployed $(PROJECTS) to $$MYSERVER/me\nTo update gh-pages on github.com do:\
		\n\tgit checkout gh-pages && make deploy && git checkout master\n"

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
