<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sg:extract-from-docx"
    name="extract-from-docx"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sg="http://www.sgmlguru/ns/xproc/steps"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    xmlns:pxp="http://exproc.org/proposed/steps"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    version="1.0">
    
    <p:input port="xslt-params" kind="parameter"/>

    
    <p:output port="result" sequence="true">
        <p:pipe port="result" step="last"/>
    </p:output>


    <!-- Input path -->
    <p:option name="input-base-uri" select="'file:/home/ari/Documents/projects/docx2db/test/sources'">
        <p:documentation>
            <p>Source document(s) URI. Every document ending with suffix <em>$include-filter</em> in this folder and its subfolders is transformed.</p>
        </p:documentation>
    </p:option>

    <p:option name="include-filter" select="'docx'">
        <p:documentation>
            <p>The file suffix of the input files to be converted. Leaving this empty will attempt to convert everything, so don't do it unless you know what you're doing.</p>
        </p:documentation>
    </p:option>
    
    <!-- Exclude filter -->
    <p:option name="exclude-filter" select="'~'">
        <p:documentation>
            <p>Pattern in files to be excluded.</p>
        </p:documentation>
    </p:option>

    <!-- Output base URI -->
    <p:option name="output-base-uri" select="'file:/home/ari/Documents/projects/docx2db/test/tmp/xml'">
        <p:documentation>
            <p>Output base URI for the transformed files, debug, etc. Output folders for these are defined alsewhere.</p>
        </p:documentation>
    </p:option>

    <!-- Enable verbose output -->
    <p:option name="verbose" select="'false'"/>

    <!-- Enable debug output (intermediate results on pipeline) -->
    <p:option name="debug" select="'false'"/>

    
    <!-- XProc Tools -->
    <p:import href="../xproc-tools/xproc/recursive-directory-list.xpl"/>
    <p:import href="../xproc-tools/xproc/load-sequence-from-file.xpl"/>
    <p:import href="../xproc-tools/xproc/threaded-xslt.xpl"/>

    <!-- Calabash extensions -->
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    

    <!-- Input documents list -->
    <ccproc:recursive-directory-list name="source-files">
        <p:with-option name="path" select="$input-base-uri"/>
        <!-- Add @uri to c:file elements -->
        <p:with-option name="resolve" select="'true'"/>
        <p:with-option name="include-filter" select="$include-filter"/>
        <p:with-option name="exclude-filter" select="$exclude-filter"/>
    </ccproc:recursive-directory-list>
    
    <!-- URI-encode the directory listing -->
    <p:xslt name="uri-encoded-sources">
        <p:input port="source">
            <p:pipe port="result" step="source-files"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="xslt/uri-encode-dir-listing.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:pipe port="xslt-params" step="extract-from-docx"/>
        </p:input>
    </p:xslt>

    <p:sink/>
    

    <!-- Transform documents -->
    <p:for-each name="transform-batch">

        <p:output port="result" primary="true" sequence="true"/>

        <p:iteration-source select="//c:file">
            <p:pipe port="result" step="uri-encoded-sources"/>
        </p:iteration-source>
        
        <!-- Currently processed file, including path -->
        <p:variable name="current-file" select="/c:file/@uri"/>
        
        <!-- Currently processed file, name only -->
        <p:variable name="filename" select="/c:file/@name"/>
        
        <!-- The directory path to the currently processed file inside the input base URI -->
        <p:variable name="diff" select="substring-before(substring-after($current-file,$input-base-uri),$filename)"/>
        
        <p:choose>
            <p:when test="$verbose='true'">
                <cx:message>
                    <p:with-option name="message" select="concat('Reading docx archive ', $current-file)"/>
                </cx:message>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
        
        <!-- Extract the main document -->
        <pxp:unzip name="doc">
            <p:with-option name="href" select="$current-file"/>
            <p:with-option name="file" select="('word/document.xml')"/>
        </pxp:unzip>
        
        <!-- Extract and insert the numbering schemes, if they exist -->
        <p:try>
            <p:group>
                <pxp:unzip name="numbering">
                    <p:with-option name="href" select="$current-file"/>
                    <p:with-option name="file" select="('word/numbering.xml')"/>
                </pxp:unzip>
                
                
                <p:insert position="last-child" match="/w:document">
                    <p:input port="source">
                        <p:pipe port="result" step="doc"/>
                    </p:input>
                    <p:input port="insertion">
                        <p:pipe port="result" step="numbering"/>
                    </p:input>
                </p:insert>
            </p:group>
            <p:catch>
                <p:identity/>
            </p:catch>
        </p:try>
        
        <p:identity name="doc-num"/>
        
        <!-- Extract and insert the footnotes, if they exist -->
        <p:try>
            <p:group>
                <pxp:unzip name="footnotes">
                    <p:with-option name="href" select="$current-file"/>
                    <p:with-option name="file" select="('word/footnotes.xml')"/>
                </pxp:unzip>
                
                <p:insert position="last-child" match="/w:document" name="combined">
                    <p:input port="source">
                        <p:pipe port="result" step="doc-num"/>
                    </p:input>
                    <p:input port="insertion">
                        <p:pipe port="result" step="footnotes"/>
                    </p:input>
                </p:insert>
            </p:group>
            <p:catch>
                <p:identity/>
            </p:catch>
        </p:try>
        
        <p:identity name="doc-footnotes"/>
        
        <!-- Extract and insert the document relations, if they exist -->
        <p:try>
            <p:group>
                <pxp:unzip name="doc-relations">
                    <p:with-option name="href" select="$current-file"/>
                    <p:with-option name="file" select="('word/_rels/document.xml.rels')"/>
                </pxp:unzip>
                
                <p:insert position="last-child" match="/w:document" name="combined">
                    <p:input port="source">
                        <p:pipe port="result" step="doc-footnotes"/>
                    </p:input>
                    <p:input port="insertion">
                        <p:pipe port="result" step="doc-relations"/>
                    </p:input>
                </p:insert>
            </p:group>
            <p:catch>
                <p:identity/>
            </p:catch>
        </p:try>
        
        <p:identity/>
        
        <!-- Store the normalised docx XML -->
        <p:store>
            <p:with-option
                name="href"
                select="concat($output-base-uri,$diff,replace($filename,'\.(docx|DOCX)','.xml'))"/>
        </p:store>
        
        <p:identity>
            <p:input port="source">
                <p:empty/>
            </p:input>
        </p:identity>

    </p:for-each>


    <!-- We need an output so this will do -->
    <p:identity name="last">
        <p:input port="source">
            <p:pipe port="result" step="transform-batch"/>
        </p:input>
    </p:identity>


</p:declare-step>
