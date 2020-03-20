# README

XQuery scripts to run an XSLT pipeline from a manifest, based on Nic Gibson's XProc Tools.

* `test.xquery` shows how to run an XSLT pipeline from an XQuery
* `xlsx-unzip-test.xquery` shows the pinciple behind extracting stuff from an Excel archive using the `compress-functions.xqm` functions
* `modules/fc-functions.xqm` is an XQuery module with the necessary functions


## Modules


### `pipeline-functions.xqm`

Module namespace "http://www.sgmlguru.org/ns/pipelines".


#### `pipelines:load-manifest($uri as xs:anyURI) item()*`

Loads the pipeline manifest pointed out by `$uri` listing XSLT stylesheets into a sequence of XSLTs.


#### `pipelines:transform($doc as node(),$xslt-seq as item()*,$debug as xs:boolean) as item()`

Transforms an input document `$doc` using the sequence of XSLTs in `$xslt-seq` (presumably loaded from the manifest using `pipelines:load-manifest()`). Outputs debug from every XSLT if `$debug = true()`.


### `compress-functions.xqm`

Module namespace "http://www.sgmlguru.org/ns/sgf".


#### `sgf:xlsx-unzip($zip as xs:anyURI,$out-path as xs:anyURI) as node()`

Unzips (parts of) an Excel archive located at `$zip` to an output collection `$out-path`. Wraps the sequence of nodes in a `wrap` element.


#### `sgf:xlsx-unzip-collection($sources,$out) as xs:string*`

Unzips a collection of XLSX files in `$sources` using `sgf:xlsx-unzip()` and places the results in `$out`.
