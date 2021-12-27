<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sg:extract-from-xlsx"
    name="extract-from-xlsx"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sg="http://www.sgmlguru/ns/xproc/steps"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    xmlns:pxp="http://exproc.org/proposed/steps"
    xmlns:sml="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    version="1.0">
    
    <p:input port="xslt-params" kind="parameter"/>

    
    <p:output port="result" sequence="true">
        <p:pipe port="result" step="last"/>
    </p:output>


    <!-- Input path -->
    <p:option name="input-base-uri" select="'file:/home/ari/Documents/projects/findcourses/poc/sources'">
        <p:documentation>
            <p>Source document(s) URI. Every document ending with suffix <em>$include-filter</em> in this folder and its subfolders is transformed.</p>
        </p:documentation>
    </p:option>

    <p:option name="include-filter" select="'xlsx'">
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
    <p:option name="output-base-uri" select="'file:/home/ari/Documents/projects/findcourses/poc/tmp/xml'">
        <p:documentation>
            <p>Output base URI for the transformed files, debug, etc. Output folders for these are defined alsewhere.</p>
        </p:documentation>
    </p:option>

    <!-- Enable verbose output -->
    <p:option name="verbose" select="'true'"/>

    <!-- Enable debug output (intermediate results on pipeline) -->
    <p:option name="debug" select="'false'"/>

    
    <!-- XProc Tools -->
    <p:import href="http://xml.corbas.co.uk/xml/xproc-tools/recursive-directory-list.xpl"/>
    <p:import href="http://xml.corbas.co.uk/xml/xproc-tools/load-sequence-from-file.xpl"/>
    <p:import href="http://xml.corbas.co.uk/xml/xproc-tools/threaded-xslt.xpl"/>

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
            <p:pipe port="xslt-params" step="extract-from-xlsx"/>
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
                    <p:with-option name="message" select="concat('Reading xlsx archive ', $current-file)"/>
                </cx:message>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
        
        <!-- We'll need the following at least:
             xl/workbook.xml 
             xl/worksheets/sheet1.xml
             xl/sharedStrings.xml
             xl/worksheets/_rels/sheet1.xml.rels
             -->
        
        <!-- Extract the main document -->
        <pxp:unzip name="doc">
            <p:with-option name="href" select="$current-file"/>
            <p:with-option name="file" select="('xl/workbook.xml')"/>
        </pxp:unzip>
        
        <!-- Extract and insert sheet1 (only supporting one for the PoC) -->
        <p:try>
            <p:group>
                <pxp:unzip name="sheets">
                    <p:with-option name="href" select="$current-file"/>
                    <p:with-option name="file" select="('xl/worksheets/sheet1.xml')"/>
                </pxp:unzip>
                
                
                <p:insert position="last-child" match="/sml:workbook/sml:sheets">
                    <p:input port="source">
                        <p:pipe port="result" step="doc"/>
                    </p:input>
                    <p:input port="insertion">
                        <p:pipe port="result" step="sheets"/>
                    </p:input>
                </p:insert>
            </p:group>
            <p:catch>
                <p:identity/>
            </p:catch>
        </p:try>
        
        <p:identity name="sheets-output"/>
        
        <!-- Extract and insert shared strings -->
        <p:try>
            <p:group>
                <pxp:unzip name="shared-strings">
                    <p:with-option name="href" select="$current-file"/>
                    <p:with-option name="file" select="('xl/sharedStrings.xml')"/>
                </pxp:unzip>
                
                <p:insert position="last-child" match="/sml:workbook" name="combined">
                    <p:input port="source">
                        <p:pipe port="result" step="sheets-output"/>
                    </p:input>
                    <p:input port="insertion">
                        <p:pipe port="result" step="shared-strings"/>
                    </p:input>
                </p:insert>
            </p:group>
            <p:catch>
                <p:identity/>
            </p:catch>
        </p:try>
        
        <p:identity name="sheets-shared-strings"/>
        
        <!-- Extract and insert the spreadsheet relations, if they exist -->
        <p:try>
            <p:group>
                <pxp:unzip name="spreadsheet-relations">
                    <p:with-option name="href" select="$current-file"/>
                    <p:with-option name="file" select="('xl/worksheets/_rels/sheet1.xml.rels')"/>
                </pxp:unzip>
                
                <p:insert position="last-child" match="/sml:workbook" name="combined">
                    <p:input port="source">
                        <p:pipe port="result" step="sheets-shared-strings"/>
                    </p:input>
                    <p:input port="insertion">
                        <p:pipe port="result" step="spreadsheet-relations"/>
                    </p:input>
                </p:insert>
            </p:group>
            <p:catch>
                <p:identity/>
            </p:catch>
        </p:try>
        
        <p:identity/>
        
        <!-- Store the normalised xlsx XML -->
        <p:store indent="true">
            <p:with-option
                name="href"
                select="concat($output-base-uri,$diff,replace($filename,'\.(xlsx|XLSX)','.xml'))"/>
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
