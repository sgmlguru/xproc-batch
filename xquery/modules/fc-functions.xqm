xquery version "3.1";

module namespace fc = "http://www.sgmlguru.org/ns/fc";
declare namespace data = "http://www.corbas.co.uk/ns/transforms/data";
import module namespace transform = "http://exist-db.org/xquery/transform";

(: Load XSLT stylesheets from a manifest :)
declare function fc:load-manifest($uri) as item()* {
    let $manifest := doc($uri)
    let $doc := tokenize(base-uri($manifest),'/')[last()]
    let $base-uri := substring-before(base-uri($manifest),$doc)
    let $xslts := for $xsl in $manifest//data:group[@enabled='true' or not(@enabled)]
                        let $base := string($xsl/@xml:base)
                        for $item in $xsl//data:item[@enabled='true' or not(@enabled)]
                            return doc(concat($base-uri,$base,$item/@href))
    
    return $xslts
};

(: Just for investigative purposes :)
declare function fc:remove-top($xslt-seq) {
    let $tr := subsequence($xslt-seq,2,count($xslt-seq))
    return if (empty($tr) = false()) then ($xslt-seq,fc:remove-top($tr)) else ($xslt-seq)
    
};

(: Transform the input using a sequence of XSLTs :)
declare function fc:transform($doc as node(),$xslt-seq as item()*,$debug as xs:boolean) as item() {
    let $out := transform:transform($doc,$xslt-seq[1],())
    let $debug := if ($debug = true())
                  then (xmldb:store('/db/test',
                                     concat(tokenize(base-uri($xslt-seq[1]),'/')[last()],'.xml'),
                                     $out))
                  else ()
    let $tr := subsequence($xslt-seq,2,count($xslt-seq))
    return (if (empty($tr) = false()) then (fc:transform($out,$tr,true())) else ($out))
    
};

(: Debug output :)
declare function fc:save-debug($debug-uri,$xslt) {
    <debug>
        <uri>{$debug-uri}</uri>
        <xslt>{base-uri($xslt)}</xslt>
    </debug>
};
