#!/usr/bin/make -f

default: clean build

build:
##
	@echo "   Copying source files…"
	@mkdir ./iphone
	@cp -R ./src/img ./iphone/img
	@cp ./src/vnet.* .
##
	@echo "   Replacing image paths…"
	@perl -p -i -e "s/=\"(img\/.*)\"/=\"iphone\/\\1\"/g;" ./vnet.html ./vnet.manifest
##
	@echo "   Setting version and build date…"
	@perl -p -i -e "s/v(\@VERSION\@)/v`head -1 src/VERSION`/g;" ./vnet.html ./vnet.manifest
	@perl -p -i -e "s/(\@BUILDDATE\@)/`date`/g;" ./vnet.html ./vnet.manifest
##
	@echo "   Compressing HTML file…"
	@java -jar lib/htmlcompressor-1.4.jar --type html --charset utf-8 --remove-quotes --remove-intertag-spaces --compress-js --compress-css -o ./vnet ./vnet.html
##
	@echo "   Applying gzip…"
	@gzip ./vnet
	@mv -f ./vnet.gz ./vnet
# comment next line to keep uncompressed HTML
#	@rm -f ./vnet.html
##
	@echo "Build complete. See ./vnet ./vnet.manifest"

clean:	
	@echo "   Removing vnet, vnet.html, vnet.manifest and ./iphone directory"
	@rm -rf ./vnet ./vnet.html ./vnet.manifest ./iphone
