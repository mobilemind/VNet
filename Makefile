#!/usr/bin/make -f

projname = vnet
subprojname = vnetp
projects = $(projname) $(subprojname)
htmlfiles = $(projname).html $(subprojname).html
manifests = $(projname).manifest $(subprojname).manifest
srcfiles = $(htmlfiles) $(manifests)
htmlcompressor = java -jar lib/htmlcompressor-1.5.2.jar
compressoroptions = -t html -c utf-8 --remove-quotes --remove-intertag-spaces  --remove-surrounding-spaces min --compress-js --compress-css

default: clean build

copy_src:
	@echo '   Copying source files…'
	@[[ -d build ]] || mkdir -m 744 build
	@cp -Rfp src/img build
	@($(foreach proj,$(projects), cp -fp src/$(proj).* .;))

set_ver: copy_src
	@echo '   Setting version and build date…'
	@perl -p -i -e "s/\@VERSION\@/`head -1 src/VERSION`/g;" $(srcfiles)
	@perl -p -i -e "s/\@BUILDDATE\@/`date`/g;" $(srcfiles)

validate_html: copy_src set_ver
	@echo "   Validating HTML…\n"
	@(hash tidy && ($(foreach html,$(htmlfiles), echo "$(html)"; tidy -eq $(html); [[ $$? -lt 2 ]] && echo;)))
	@echo "   Validating JavaScript…\n"
	@(hash jsl && ($(foreach html,$(htmlfiles), echo "$(html)"; jsl -process $(html) -nologo -nofilelisting -nosummary && echo ' OK';)) && echo)

compress_html: copy_src set_ver validate_html
	@echo '   Compressing HTML files…'
	@$(htmlcompressor) $(compressoroptions) --mask *.html -o build $(htmlfiles)
	@($(foreach html,$(htmlfiles), gzip -f build/$(html);))

mv2build: copy_src compress_html
	@echo '   Moving built files to web directory…'
	@($(foreach proj,$(projects), mv -f build/$(proj).html.gz build/$(proj);))
	@($(foreach manifest,$(manifests), mv -f $(manifest) build;))
	@chmod -R 744 build

build: mv2build
	@echo "   Removing temporary $(projname) $(subprojname) $(srcfiles) and *.bak"
	@rm -rf $(projname) $(subprojname) $(srcfiles) *.bak
	@echo "Build complete. See build/ directory for $(projname), $(subprojname), $(projname).manifest, and $(imgdir)/.\n"

clean:
	@echo '   Cleaning build folder and root…' && rm -rf build/* $(projname) $(subprojname) $(srcfiles) *.bak
