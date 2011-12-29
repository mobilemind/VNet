VNet
==========
The "VNet" bookmarklet streamlines logging in to Roving Planet, “VisitorNet” sites that control access to WiFi networks. The bookmarklet will paste in the Username, check the “Agree to Terms” box and set input focus on the password field.

The sister version "VNet+P" adds the capability to complete the password too. Generally not a good idea, unless it is a low stakes environment.

Install
----------
**Mobile Safari**
The [hosted VNet page](http://mmind.me/vnet) is a form that will create the bookmarklet and explains how to store and edit the bookmarklet on your iPad or iPhone. Tap the [hosted VNet page](http://mmind.me/vnet) link and follow the instructions.

Usage
----------
Connect to the WiFi network and open a web page. The VisitorNet sign-in page should appear.

Activate the VNet bookmarklet (tap on the link for it in the bookmark bar or use Bookmarks menu). The default bookmark title is usually “login ___name___…” where ___name___ is the first part of your Username (email).

The bookmarklet created via installation will paste in the Username, check the “Agree to Terms” box and set input focus on the password field of the VisitorNet sign-in form.

Usage Requirements
----------
Web browser. Tested with Firefox 6.0.x, Safari 5.0.x, Mobile Safari 4.x, and IE 8.

License
----------
MIT License - [http://www.opensource.org/licenses/mit-license.php](http://www.opensource.org/licenses/mit-license.php)

VNet
Copyright (c) 2011 Tom King <mobilemind@pobox.com>

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

Developer
----------
Tom King

Source Code Notes
----------
Source code is available. The bookmark JavaScript was written to be as small as practical and URL-encoded by hand. Sorry if it isn't easy to read.

Build Requirements & Notes
----------
The make file requires the Java-based htmlcompressor and yuicompressor included in the lib folder. It also requires the bash shell, make, perl, tidy, jsl, gzip and optionally uses growlnotify.
Required utilities are easily installed on Mac OS X with brew or on Windows with Cygwin.

Use “make” to create the HTML page and manifest.

Comment-out the annotated line in the Makefile to leave the vnet HTML file uncompressed with a .html extension (default is to gzip compress it and remove the file extension).
