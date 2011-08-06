#!/usr/bin/make -f

## MACROS
#HTMLCOMPRESS = java -jar ./htmlcompressor-1.4.jar --type html --charset utf-8 --remove-quotes --remove-intertag-spaces --compress-js --compress-css -o $2 $1

default: clean build

build:
	@echo "   Copying source files…"
	@mkdir ./iphone
	@cp -R ./src/img ./iphone/img
	@cp ./src/vnet.* .
	@echo "   Replacing image paths…"
	@perl -p -i -e "s/=\"(img\/.*)\"/=\"iphone\/\\1\"/g;" ./vnet.html
	@perl -p -i -e "s/^(img\/.*)/iphone\/\\1/g;" ./vnet.manifest
	@echo "   Compressing HTML file…"
	@java -jar lib/htmlcompressor-1.4.jar --type html --charset utf-8 --remove-quotes --remove-intertag-spaces --compress-js --compress-css -o ./vnet ./vnet.html
	@rm -f ./vnet.html
	@echo "Build complete. See ./vnet ./vnet.manifest"

clean:	
	@echo "   Removing vnet, vnet.html, vnet.manifest and ./iphone directory"
	@rm -rf ./vnet ./vnet.html ./vnet.manifest ./iphone


