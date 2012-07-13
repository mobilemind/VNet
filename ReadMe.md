# VNet
The “VNet” bookmarklet streamlines logging in to Roving Planet, “VisitorNet” sites that
control access to WiFi networks. The bookmarklet will paste in the Username, check the
“Agree to Terms” box and set input focus on the password field.

The sister version "VNet+P" adds the capability to complete the password too. Generally
not a good idea, unless it is a low stakes environment.

## Install
**Mobile Safari**
The [hosted VNet page][vnet] is a form that will create the bookmarklet and
explains how to store and edit the bookmarklet on your iPad or iPhone. Tap the
[hosted VNet page][vnet] link and follow the instructions.

The [hosted VNet+P page](http://mmind.me/vnetp) is a form that will create a
bookmarklet that fills all credentials *and* automatically submits the completed login form.

The same forms are also hosted on github as [github hosted VNet page](http://mobilemind.github.com/VNet/vnet.html)
and [github hosted VNet+P page](http://mobilemind.github.com/VNet/vnetp.html).

[vnet]: http://mmind.me/vnet

## Use
Connect to the WiFi network and open a web page. The VisitorNet sign-in page should appear.

Activate the VNet bookmarklet (tap on the link for it in the bookmark bar or use Bookmarks
menu). The default bookmark title is usually “login ___name___…” where ___name___ is the
first part of your Username (email).

The bookmarklet created via installation will paste in the Username, check the “Agree to
Terms” box and set input focus on the password field of the VisitorNet sign-in form.
_Note: The VNet+P version will also enter the stored password and submit the form._

### Compatibility
Requires a browser that supports `javascript:` bookmarks.

Tested with Firefox 6.x - 12.x, Google Chrome 10.x - 19.x, IE 8, Safari 5.0.x - 5.1.x,
and Mobile Safari 4.x - 5.x.

## License
MIT License - <http://www.opensource.org/licenses/mit-license.php>

VNet
Copyright (c) 2011-2012 Tom King <mobilemind@pobox.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Build Requirements
The VNet Makefile requires htmlcompressor. The htmlcompressor project has its own license
and sub-projects. End-users are responsible for obtaining a htmlcompressor and its related
components, under their respective license terms.

For htmlcompressor see: <https://code.google.com/p/htmlcompressor/>

The VNet Makefile also requires bash shell, make, gzip, perl, tidy (or tidy-html5), jsl,
node (nodejs on Windows) and optionally uses growlnotify. Required utilities are easily
installed on Mac OS X via homebrew or on Windows via Cygwin setup.

The W3C tidy-html5 is available here: <http://w3c.github.com/tidy-html5/>

**Mac**

* For utilities such as **jsl** and **node** using homebrew see: <http://mxcl.github.com/homebrew/>
* For **growlnotify** (requires Growl), see: <http://growl.info>

**Win**

* For **Cygwin** and related utilities such as **make**, **gzip**, **perl**, **tidy**, **nodejs**,
see: <http://www.cygwin.com/>
* For **growlnotify** (requires Growl for Windows), see: <http://growlforwindows.com>
* For **jsl**, see: <http://www.javascriptlint.com/>

## Build
Use `make` at the command shell prompt to create the VNet HTML pages and manifests.
See `/web/` directory for results.
