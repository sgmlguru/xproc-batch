xquery version "3.1";

module namespace pipelines = "http://www.sgmlguru.org/ns/pipelines";
declare namespace data = "http://www.corbas.co.uk/ns/transforms/data";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";


(: Load XSLT stylesheets and params from a manifest :)
declare function pipelines:load-manifest($uri as xs:anyURI) as item()* {
    let $manifest := doc($uri)
    let $doc := tokenize(base-uri($manifest),'/')[last()]
    let $base-uri := substring-before(base-uri($manifest),$doc)
    let $meta-xsl := doc('xslt/meta2param.xsl')
    
    let $xslts := for $xsl in $manifest//data:group[@enabled='true' or not(@enabled)]
                        let $base := string($xsl/@xml:base)
                        for $item in $xsl//data:item[@enabled='true' or not(@enabled)]
                            return (
                            doc(concat($base-uri,$base,$item/@href)),
                            <parameters>{
                                for $param in $item/data:meta
                                    return transform:transform($param,$meta-xsl,())
                            }</parameters>
                            )
    
    return $xslts
};


(: Transform the input using a sequence of XSLTs :)
declare function pipelines:transform($doc as node(),$xslt-seq as item()*,$debug as xs:boolean,$tmp-uri as xs:anyURI?) as item() {
    let $filename := tokenize(base-uri($doc),'/')[last()]
    let $base-uri := if ($tmp-uri !='') then ($tmp-uri) else (substring-before(base-uri($doc),concat('/',$filename)))
    let $output-collections := if ($tmp-uri = '') then (pipelines:create-target-collections($base-uri,$debug)) else ($tmp-uri)
    let $out := transform:transform($doc,$xslt-seq[1],$xslt-seq[2])
    let $save-debug := if ($debug = true())
                       then (xmldb:store($output-collections,
                             concat(tokenize(base-uri($xslt-seq[1]),'/')[last()],'.xml'),
                             $out))
                       else ()
    let $tr := subsequence($xslt-seq,3,count($xslt-seq))
    return (if (empty($tr) = false()) then (pipelines:transform($out,$tr,$debug,$base-uri)) else ($out))
};


(: Create target collections for pipeline output - everything should be created in a timeDate collection :)
declare function pipelines:create-target-collections($uri as xs:anyURI,$debug as xs:boolean) as xs:anyURI {
    let $date-time := translate(substring-before(string(fn:current-dateTime()),'.'),':-T','')
    let $base := if (xmldb:collection-available(concat($uri,'/tmp'))) then (concat($uri,'/tmp')) else (xmldb:create-collection($uri,'tmp'))
    let $tmp := if (xmldb:collection-available(concat($base,'/',$date-time))) then (concat($base,'/',$date-time)) else (xmldb:create-collection($base,$date-time))
    let $xml-out := if (xmldb:collection-available(concat($tmp,'/xml'))) then (concat($tmp,'/xml')) else (xmldb:create-collection($tmp,'xml'))
    let $debug-out := if (xmldb:collection-available(concat($tmp,'/debug'))) then (concat($tmp,'/debug')) else (xmldb:create-collection($tmp,'debug'))
    let $out := if (xmldb:collection-available(concat($tmp,'/out'))) then (concat($tmp,'/out')) else (xmldb:create-collection($tmp,'out'))
    return xs:anyURI($tmp)
};
