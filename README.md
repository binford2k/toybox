Introduction
============

This is a simple VirtualBox image builder with fewer dependencies than Veewee.

It will read in a config.yaml file with the following structure:

    --- 
    name:     "Puppet"
    ostype:   "RedHat_64"
    iso:      "CentOS-6.3-x86_64-minimal.iso"
    uri:      "http://mirror.cisp.com/CentOS/6.3/isos/x86_64/CentOS-6.3-x86_64-minimal.iso"
    memory:   "512"
    disksize: "8096"
    bootwait: "10"

Toybox will create a new VBox instance with the requested name and ostype and
will set the parameters of the instance to match memory and disksize (in MB).
If the iso path provided does not exist, then it will be downloaded from uri.
Toybox will then wait for bootwait seconds before passing in kickstart info.

If you provide the optional kickstart parameter, the instance can load an arbirtrary
kickstart file from whatever URI provided. Otherwise, Toybox will serve ks.cfg
from the current working directory.

Toybox will also serve up the VBoxGuestAdditions.iso if it exists in $CWD for installation by the VM.

Contact
=======

* Author: Ben Ford
* Email: ben.ford@puppetlabs.com
* Twitter: @binford2k
* IRC (Freenode): binford2k

Credit
=======

The development of this code was sponsored by the ISD group at Salesforce.com.

License
=======

Copyright (c) 2012 Puppet Labs, info@puppetlabs.com  
Copyright (c) 2012 Salesforce.com, goehmen@salesforce.com

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