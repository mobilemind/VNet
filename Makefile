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
TMPDIR := $$HOME/.$(PROJ)
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
HTMLCOMPRESSORPATH := $(shell [[ 'cygwin' == $$OSTYPE ]] && echo "`cygpath -w $(COMMONLIB)`\\" || echo "$(COMMONLIB)/")
HTMLCOMPRESSOR := java -jar '$(HTMLCOMPRESSORPATH)$(HTMLCOMPRESSORJAR)'
COMPRESSOPTIONS := -t html -c utf-8 --remove-quotes --remove-intertag-spaces --remove-surrounding-spaces min --remove-input-attr --remove-form-attr --remove-script-attr --remove-http-protocol --compress-js --compress-css --nomunge
TIDY := $(shell hash tidy-html5 2>/dev/null && echo 'tidy-html5' || (hash tidy 2>/dev/null && echo 'tidy' || exit 1))
JSL := $(shell hash jsl 2>/dev/null && echo 'jsl' || exit 1)
GRECHO = $(shell hash grecho &> /dev/null && echo 'grecho' || echo 'printf')
REPLACETOKENS = perl -p -i -e 's/$(MMVERSION)/$(VERSION)/g;' $@; perl -p -i -e 's/$(MMBUILDDATE)/$(BUILDDATE)/g;' $@

default: $(PROJECTS) | $(BUILDDIR) $(WEBDIR) $(IMGDIR)
	@(chmod -R 755 $(WEBDIR); $(GRECHO) 'make:' "Done. See $(PROJ)/$(WEBDIR) directory for v$(VERSION).\n" )

$(PROJ)  $(SUBPROJ): $(MANIFESTS) $(COMPRESSEDFILES) | $(WEBDIR)
	@printf "\nCopying built files...\n"
	@cp -fp $(BUILDDIR)/$@.html.gz $(WEBDIR)/$@
	@cp -fp $(BUILDDIR)/$@.manifest $(WEBDIR)
	@cp -Rfp $(SRCDIR)/$(IMGDIR) $(WEBDIR)

# run through html compressor and into gzip
%.html.gz: %.html | $(BUILDDIR)
	@echo "Compressing $^..."
	@$(HTMLCOMPRESSOR) $(COMPRESSOPTIONS) $(BUILDDIR)/$^ | gzip -f9 > $(BUILDDIR)/$@

# copy HTML to $(BUILDDIR) and replace tokens, then check with tidy & jsl (JavaScript Lint)
%.html: $(SRCDIR)/%.html $(VERSIONTXT) | $(BUILDDIR)
	@printf "\n$@: validate with $(TIDY) and $(JSL)\n"
	@cp -f $(SRCDIR)/$@ $(BUILDDIR)
	@(cd $(BUILDDIR); \
		$(REPLACETOKENS); \
		$(TIDY) -eq $@; [[ $$? -lt 2 ]] && true; \
		$(JSL) -process $@ -nologo -nofilelisting -nosummary )

# copy manifest to $(BUILDDIR) and replace tokens
%.manifest: $(SRCDIR)/%.manifest $(VERSIONTXT) | $(BUILDDIR)
	@printf "\n$@\n"
	@cp -fp $(SRCDIR)/$@ $(BUILDDIR)
	@(cd $(BUILDDIR); $(REPLACETOKENS))

# deploy
.PHONY: deploy
deploy: default
	@echo "Deploy to: $$MYSERVER/me"
	@rsync -ptv --executability $(WEBDIR)/$(PROJ) $(WEBDIR)/$(SUBPROJ) $(WEBDIR)/*.manifest "$$MYUSER@$$MYSERVER:$$MYSERVERHOME/me"
	@rsync -pt $(WEBDIR)/$(IMGDIR)/*.* "$$MYUSER@$$MYSERVER:$$MYSERVERHOME/me/$(IMGDIR)"
	@printf "\n\nPreparing for gh-pages, copying to: $(TMPDIR)\n"
	@[[ -d $(TMPDIR)/$(IMGDIR) ]] || mkdir -pv $(TMPDIR)/$(IMGDIR)
	@rsync -ptv --executability $(WEBDIR)/$(PROJ) $(WEBDIR)/$(SUBPROJ) $(WEBDIR)/*.manifest $(TMPDIR)
	@rsync -pt $(WEBDIR)/$(IMGDIR)/*.* $(TMPDIR)/$(IMGDIR)
	@rsync -pt $(VERSIONTXT) $(TMPDIR)
	@$(GRECHO) '\nmake:' "Done. Deployed v$(VERSION) $(PROJECTS) to $$MYSERVER/me \
		\nTo update gh-pages on github.com do:\n\tgit checkout gh-pages && make deploy && git checkout master\n"

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
	@echo 'Cleaning build directory, web directory, and $(TMPDIR)'
	@rm -rf $(BUILDDIR)/* $(WEBDIR)/* || true
	@[[ -d $(TMPDIR) ]] && rm -rfv $(TMPDIR) || true
