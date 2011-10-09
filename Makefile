#!/usr/bin/make -f

default: clean build

build:
##
	@echo "   Copying source files…"
	@mkdir ./iphone
	@cp -R ./src/img ./iphone/img
	@cp ./src/vnet.* .
	@cp ./src/vnetp.* .
##
	@echo "   Replacing image paths…"
	@perl -p -i -e "s/=\"(img\/.*)\"/=\"iphone\/\\1\"/g;" ./vnet.html ./vnetp.html ./vnet.manifest
##
	@echo "   Setting version and build date…"
	@perl -p -i -e "s/v(\@VERSION\@)/v`head -1 src/VERSION`/g;" ./vnet.html ./vnetp.html ./vnet.manifest
	@perl -p -i -e "s/(\@BUILDDATE\@)/`date`/g;" ./vnet.html ./vnetp.html ./vnet.manifest
##
	@echo "   Compressing HTML files…"
	@java -jar lib/htmlcompressor-1.4.jar --type html --charset utf-8 --remove-quotes --remove-intertag-spaces --compress-js --compress-css -o ./vnet ./vnet.html
	@java -jar lib/htmlcompressor-1.4.jar --type html --charset utf-8 --remove-quotes --remove-intertag-spaces --compress-js --compress-css -o ./vnetp ./vnetp.html
##
	@echo "   Applying gzip…"
	@gzip ./vnet
	@mv -f ./vnet.gz ./vnet
	@gzip ./vnetp
	@mv -f ./vnetp.gz ./vnetp
# comment next line to keep uncompressed HTML
	@rm -f ./vnet.html ./vnetp.html
##
	@echo "Build complete. See ./vnet ./vnetp ./vnet.manifest"

clean:	
	@echo "   Removing vnet, vnet.html, vnetp, vnetp.html, vnet.manifest and ./iphone directory"
	@rm -rf ./vnet ./vnet.html ./vnetp ./vnetp.html ./vnet.manifest ./iphone
