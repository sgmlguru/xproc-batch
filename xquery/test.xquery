xquery version "3.1";

import module namespace fc = "http://www.sgmlguru.org/ns/fc" at "modules/fc-functions.xqm";

let $source := '/db/test/sources/input.xml'

let $manifest-uri := '/db/repos/xslt-pipeline/pipelines/test-manifest.xml'

let $xslt-seq := fc:load-manifest($manifest-uri)

let $debug := true()

(: Investigates removing the topmost XSLT from the sequence of loaded XSLT stylesheets :)
let $remove-top := <root>{fc:remove-top($xslt-seq)}</root>

return fc:transform(doc($source),$xslt-seq,$debug)

(:return $xslt-seq:)
