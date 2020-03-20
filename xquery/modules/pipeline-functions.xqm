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
declare function pipelines:transform($doc as node(),$xslt-seq as item()*,$debug as xs:boolean) as item() {
    let $out := transform:transform($doc,$xslt-seq[1],$xslt-seq[2])
    let $save-debug := if ($debug = true())
                       then (xmldb:store('/db/test',
                             concat(tokenize(base-uri($xslt-seq[1]),'/')[last()],'.xml'),
                             $out))
                       else ()
    let $tr := subsequence($xslt-seq,3,count($xslt-seq))
    return (if (empty($tr) = false()) then (pipelines:transform($out,$tr,$debug)) else ($out))
};

