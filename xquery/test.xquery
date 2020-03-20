xquery version "3.1";

import module namespace pipelines = "http://www.sgmlguru.org/ns/pipelines" at "modules/pipeline-functions.xqm";

(: Single file :)
let $source := '/db/test/sources/input.xml'

(: Collection of normalised XML files :)
let $sources := '/db/test/sources'

(: Manifest URI :)
let $manifest-uri := '/db/repos/xslt-pipeline/pipelines/test-manifest.xml'

(: Sequence of XSLTs loaded from manifest; only for single-file test :)
let $xslt-seq := pipelines:load-manifest($manifest-uri)

(: Save debug output? :)
let $debug := true()

(: Use as base URI, in which to create temp location for output :)
let $out-base := '/db/test'

(: Create collectios for output; returns the tmp URI :)
let $create-collections := pipelines:create-target-collections($out-base,$debug)

(: Name of the single input file test :)
let $filename := tokenize($source,'/')[last()]

(:return pipelines:transform($filename,doc($source),$xslt-seq,$debug,$create-collections):)

(:return $create-collections:)

return pipelines:transform-collection($sources,$manifest-uri,$debug,$out-base)
