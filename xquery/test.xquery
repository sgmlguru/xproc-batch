xquery version "3.1";

import module namespace pipelines = "http://www.sgmlguru.org/ns/pipelines" at "modules/pipeline-functions.xqm";

let $source := '/db/test/sources/input.xml'
let $manifest-uri := '/db/repos/xslt-pipeline/pipelines/test-manifest.xml'
let $xslt-seq := pipelines:load-manifest($manifest-uri)
let $debug := true()

let $out-base := '/db/test'
let $create-collections := pipelines:create-target-collections($out-base,$debug)

let $filename := tokenize($source,'/')[last()]

return pipelines:transform($filename,doc($source),$xslt-seq,$debug,$create-collections)


(:return $create-collections:)
