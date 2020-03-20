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
declare function pipelines:transform($filename as xs:string,$doc as node(),$xslt-seq as item()*,$debug as xs:boolean,$tmp-uri as xs:anyURI) as item() {
    (: Transform input using the first XSLT in the sequence :)
    let $out := transform:transform($doc,$xslt-seq[1],$xslt-seq[2])
    
    (: Save debug :)
    let $debug-output := if ($debug = true()) then pipelines:save-debug(xs:anyURI(concat($tmp-uri,'/debug/')),$filename,$xslt-seq[1],$out) else ()
    
    (: Pick the nest XSLT in sequence (remember that odd positions are XSLTs and even positions are params) :)
    let $tr := subsequence($xslt-seq,3,count($xslt-seq))
    
    return 
        if (empty($tr) = false())
        then (pipelines:transform($filename,$out,$tr,$debug,$tmp-uri))
        else xmldb:store(concat($tmp-uri,'/out'),$filename,$out)
};


(: Produce debug output :)
declare function pipelines:save-debug($uri as xs:anyURI,$filename as xs:string,$xsl as node(),$contents as node()) {
    let $current-collection := if (xmldb:collection-available(concat($uri,'/',$filename))) then (concat($uri,'/',$filename)) else (xmldb:create-collection($uri,$filename))
    return 
        xmldb:store($current-collection,concat(tokenize(base-uri($xsl),'/')[last()],'.xml'),$contents)
};


(: Create target collections for pipeline output - everything should be created in a timeDate collection :)
declare function pipelines:create-target-collections($uri as xs:anyURI,$debug as xs:boolean) as xs:anyURI {
    let $date-time := translate(substring-before(string(fn:current-dateTime()),'.'),':-T','')
    let $base := if (xmldb:collection-available(concat($uri,'/tmp'))) then (concat($uri,'/tmp')) else (xmldb:create-collection($uri,'tmp'))
    let $tmp := if (xmldb:collection-available(concat($base,'/',$date-time))) then (concat($base,'/',$date-time)) else (xmldb:create-collection($base,$date-time))
    let $xml-out := if (xmldb:collection-available(concat($tmp,'/xml'))) then () else (xmldb:create-collection($tmp,'xml'))
    let $debug-out := if (xmldb:collection-available(concat($tmp,'/debug')) or $debug = false()) then () else (xmldb:create-collection($tmp,'debug'))
    let $out := if (xmldb:collection-available(concat($tmp,'/out'))) then () else (xmldb:create-collection($tmp,'out'))
    return xs:anyURI($tmp)
};
