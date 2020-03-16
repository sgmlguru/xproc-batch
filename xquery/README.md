# README

XQuery scripts to run an XSLT pipeline from a manifest, based on Nic Gibson's XProc Tools.

* `test.xquery` is a test script that shows the basic principle
* `modules/fc-functions.xqm` is an XQuery module with the necessary functions


## Functions

Module namespace "http://www.sgmlguru.org/ns/fc".


### `fc:load-manifest($uri as xs:anyURI) item()*`

Loads the pipeline manifest pointed out by `$uri` listing XSLT stylesheets into a sequence of XSLTs.


### `fc:transform($doc as node(),$xslt-seq as item()*,$debug as xs:boolean) as item()`

Transforms an input document `$doc` using the sequence of XSLTs in `$xslt-seq` (presumably loaded from the manifest using `fc:load-manifest()`). Outputs debug from every XSLT if `$debug = true()`.

