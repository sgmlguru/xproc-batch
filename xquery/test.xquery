xquery version "3.1";

import module namespace pipelines = "http://www.sgmlguru.org/ns/pipelines" at "modules/pipeline-functions.xqm";
import module namespace sgf = "http://www.sgmlguru.org/ns/sgf" at "modules/compress-functions.xqm";

(: Single file :)
let $source := '/db/test/sources/input.xml'

(: Collection of normalised XML files :)
let $sources := '/db/test/sources'

(: Collection of XLSX files :)
let $xlsx-sources := "/db/test/xlsx-sources"

(: A single XLSX :)
let $single-xlsx := '/db/test/xlsx-sources/Morley_College.xlsx'

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

(: Unzip and normalise XLSX :)
(:let $xlsx2xml := for $zip in collection($xlsx-sources) return sgf:xlsx-unzip(base-uri($zip),concat($create-collections,'/xml')):)

let $xlsx2xml := sgf:xlsx-unzip-collection( $xlsx-sources,$create-collections)

(:return pipelines:transform($filename,doc($source),$xslt-seq,$debug,$create-collections):)

(:return $create-collections:)

(:return pipelines:transform-collection($sources,$manifest-uri,$debug,$out-base):)

(:return sgf:xlsx-unzip($single-xlsx,$save-xslx2xml):)

return $xlsx2xml
