xquery version "3.1";

import module namespace sgf = "http://www.sgmlguru.org/ns/sgf" at "modules/compress-functions.xqm";

let $zip-path := '/db/test/xml/Activate_Learning.xlsx'
let $out := '/db/test/out'

return sgf:xlsx-unzip($zip-path,$out)