xquery version "3.1";

(: Functions to extract content from an Excel xlsx archive; note that this does NOT handle everything :)

module namespace sgf = "http://www.sgmlguru.org/ns/sgf";
import module namespace compression = "http://exist-db.org/xquery/compression";


(: Filtering Excel archive content :)
declare function sgf:filter($path as xs:string, $type as xs:string, $param as item()*) as xs:boolean{
    if (ends-with($path,'workbook.xml') or ends-with($path,'sheet1.xml') or ends-with($path,'sharedStrings.xml') or ends-with($path,'sheet1.xml.rels')) then (true()) else (false())
};


(: Processing Excel archive content (let everything through for now) :)
declare function sgf:process($path as xs:string,$type as xs:string, $data as item()? , $param as item()*) {
    $data
};


(: Extract parts of an Excel archive :)
declare function sgf:xlsx-unzip($zip as xs:string,$out-path as xs:string) as xs:string {
    let $filter := util:function(QName("http://www.sgmlguru.org/ns/sgf","sgf:filter"),3)
    let $process := util:function(QName("http://www.sgmlguru.org/ns/sgf","sgf:process"),4)
    let $unzip := compression:unzip(util:binary-doc($zip),$filter,(),$process,())   (: <param collection="/db/test/out"/> :)
    return 
        xmldb:store($out-path,
                    concat(substring-before(tokenize($zip,'/')[last()],'.xlsx'),'.xml'),
                    <wrap>{$unzip}</wrap>)
};


declare function sgf:xlsx-unzip-collection($sources,$out) as xs:string* {
    let $batch := for $zip in collection($sources) return sgf:xlsx-unzip(base-uri($zip),concat($out,'/xml'))
    return $batch
};

