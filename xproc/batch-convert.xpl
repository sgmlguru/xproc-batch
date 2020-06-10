<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sg:batch-convert"
    name="batch-convert"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sg="http://www.sgmlguru/ns/xproc/steps"
    xmlns:fc="http://educations.com/XmlImport"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    xmlns:pxf="http://exproc.org/proposed/steps/file"
    version="1.0">

    <!-- XSLTs -->
    <p:input port="manifest">
        <p:documentation>
            <p>The manifest file listing the XSLT steps used by the transformation.</p>
        </p:documentation>
    </p:input>

    <!-- Optional XSLT params -->
    <p:input port="parameters" kind="parameter">
        <p:documentation>
            <p>Optional parameters for the pipelined XSLT.</p>
        </p:documentation>
    </p:input>


    <p:output port="result" sequence="true">
        <p:pipe port="result" step="last"/>
    </p:output>


    <!-- Input path -->
    <p:option name="input-base-uri">
        <p:documentation>
            <p>Source document(s) URI. Every document ending with suffix <em>$include-filter</em> in this folder and its subfolders is transformed.</p>
        </p:documentation>
    </p:option>

    <p:option name="include-filter" select="'.xml'">
        <p:documentation>
            <p>The file suffix of the input files to be converted. Leaving this empty will attempt to convert everything, so don't do it unless you know what you're doing.</p>
        </p:documentation>
    </p:option>

    <!-- Output base URI -->
    <p:option name="output-base-uri">
        <p:documentation>
            <p>Output base URI for the transformed files, debug, etc. Output folders for these are defined alsewhere.</p>
        </p:documentation>
    </p:option>

    <!-- Temp for intermediate steps -->
    <p:option name="tmp-dir">
        <p:documentation>
            <p>Folder for saving intermediate output for debug purposes.</p>
        </p:documentation>
    </p:option>

    <!-- Output DOCTYPE SYSTEM identifier -->
    <p:option name="doctype-system">
        <p:documentation>
            <p>Output DTD SYSTEM identifier.</p>
        </p:documentation>
    </p:option>

    <!-- Output DOCTYPE PUBLIC identifier -->
    <p:option name="doctype-public">
        <p:documentation>
            <p>Output DTD PUBLIC identifier.</p>
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

    <!-- Step for saving debug output -->
    <p:import href="save-debug.xpl"/>
    
    
    <!-- Create output dir -->
    <pxf:mkdir name="mkdir">
        <p:with-option name="href" select="$output-base-uri"/>
    </pxf:mkdir>
    
    <!-- Get rid of the mkdir output -->
    <p:sink>
        <p:input port="source">
            <p:pipe port="result" step="mkdir"/>
        </p:input>
    </p:sink>


    <!-- Input documents list -->
    <ccproc:recursive-directory-list name="source-files">
        <p:with-option name="path" select="$input-base-uri"/>
        <!-- Add @uri to c:file elements -->
        <p:with-option name="resolve" select="'true'"/>
        <p:with-option name="include-filter" select="$include-filter"/>
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
            <p:pipe port="parameters" step="batch-convert"/>
        </p:input>
    </p:xslt>

    <p:sink/>


    <!-- Load the XSLTs in the manifest as a sequence -->
    <ccproc:load-sequence-from-file name="manifest-sequence">
        <p:input port="source">
            <p:pipe port="manifest" step="batch-convert"/>
        </p:input>
    </ccproc:load-sequence-from-file>

    <p:sink/>


    <!-- Transform documents -->
    <p:for-each name="transform-batch">

        <p:output port="result" primary="true" sequence="true">
            <p:empty/>
        </p:output>

        <p:iteration-source select="//c:file">
            <p:pipe port="result" step="uri-encoded-sources"/>
        </p:iteration-source>
        
        
        <p:variable name="uri" select="/c:file/@uri"/>
        
        <p:variable name="filename" select="tokenize(/c:file/@uri,'/')[last()]"/>
        
        <p:variable name="path" select="substring-before($uri,$filename)"/>
        
        <p:variable name="current-file" select="concat($path,encode-for-uri($filename))"/>
        
        <p:variable name="diff" select="substring-before(substring-after($uri,$input-base-uri),tokenize($uri,'/')[last()])">
            <p:documentation>
                <p>This is the diff between the base input URI and any subfolders the input files may be placed in.</p>
            </p:documentation>
        </p:variable>
        

        <p:choose>
            <p:when test="$verbose='true'">
                <cx:message>
                    <p:with-option name="message" select="concat('Transforming ', $uri)"/>
                </cx:message>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>

        <!-- Load current input document -->
        <p:load name="load-document">
            <p:with-option name="href" select="$uri"/>
        </p:load>

        <!-- Transform using XSLTs loaded from manifest -->
        <ccproc:threaded-xslt name="conv">
            <p:input port="source">
                <p:pipe port="result" step="load-document"/>
            </p:input>
            <p:input port="stylesheets">
                <p:pipe port="result" step="manifest-sequence"/>
            </p:input>
            <p:input port="parameters">
                <p:pipe port="parameters" step="batch-convert"/>
            </p:input>
            <p:with-option name="verbose" select="$verbose"/>
        </ccproc:threaded-xslt>

        <!-- This gives us an ID transform and href on secondary output (result-document in XSLT); the XSLT handles filenaming -->
        <p:xslt name="process-output">
            <p:input port="source">
                <p:pipe port="result" step="conv"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="xslt/process-doc.xsl"/>
            </p:input>
            <p:with-param name="input-base-uri" select="$input-base-uri">
                <p:pipe port="current" step="transform-batch"/>
            </p:with-param>
            <p:with-param name="input-file" select="$uri">
                <p:pipe port="current" step="transform-batch"/>
            </p:with-param>
            <p:with-param name="output-base-uri" select="$output-base-uri">
                <p:pipe port="current" step="transform-batch"/>
            </p:with-param>
        </p:xslt>

        <!-- Get rid of the primary output; we only want the secondary -->
        <p:sink/>


        <!-- Store the secondary output from transform (this is the actual output document) -->
        <p:for-each name="store-output">
            <p:iteration-source>
                <p:pipe port="secondary" step="process-output"/>
            </p:iteration-source>

            <p:variable name="href" select="document-uri(/)">
                <p:pipe port="secondary" step="process-output"/>
            </p:variable>

            <p:choose>
                <p:when test="$verbose='true'">
                    <cx:message>
                        <p:with-option name="message" select="concat('Saving output to ', $href)"/>
                    </cx:message>
                </p:when>
                <p:otherwise>
                    <p:identity/>
                </p:otherwise>
            </p:choose>
            
            <p:choose>
                <!-- If no DTD -->
                <p:when test="$doctype-system = '' and $doctype-public = ''">
                    
                    <cx:message>
                        <p:with-option
                            name="message"
                            select="'Saving without DOCTYPE - no PUBLIC or SYSTEM identifier provided'"/>
                    </cx:message>
                    
                    <p:store encoding="UTF-8" omit-xml-declaration="false" indent="false" cdata-section-elements="fc:field">
                        <p:input port="source">
                            <p:pipe port="current" step="store-output"/>
                        </p:input>
                        <p:with-option name="href" select="document-uri(/)">
                            <p:pipe port="current" step="store-output"/>
                        </p:with-option>
                    </p:store>
                </p:when>
                <!-- If DTD -->
                <p:otherwise>
                    <p:store indent="false" cdata-section-elements="fc:field">
                        <p:input port="source">
                            <p:pipe port="current" step="store-output"/>
                        </p:input>
                        <p:with-option name="href" select="document-uri(/)">
                            <p:pipe port="current" step="store-output"/>
                        </p:with-option>
                        <p:with-option name="doctype-system" select="$doctype-system"/>
                        <p:with-option name="doctype-public" select="$doctype-public"/>
                    </p:store>
                </p:otherwise>
            </p:choose>

        </p:for-each>


        <!-- Save debug output if $debug='true' -->
        <p:choose>
            <p:when test="$debug='true'">

                <!-- Load and save orig file in tmp dir for later use -->
                <p:load name="orig-file">
                    <p:with-option name="href" select="$uri">
                        <p:pipe port="current" step="transform-batch"/>
                    </p:with-option>
                </p:load>

                <p:store indent="false">
                    <p:input port="source">
                        <p:pipe port="result" step="orig-file"/>
                    </p:input>
                    <p:with-option
                        name="href"
                        select="concat($tmp-dir,'/debug/',$diff,'/',encode-for-uri($filename),'/0-',encode-for-uri($filename))">
                        <p:pipe port="current" step="transform-batch"/>
                    </p:with-option>
                </p:store>

                <sg:save-debug>
                    <p:input port="stylesheets">
                        <p:pipe port="result" step="manifest-sequence"/>
                    </p:input>
                    <p:input port="intermediates">
                        <p:pipe port="intermediates" step="conv"/>
                    </p:input>
                    <p:with-option name="input-filename" select="encode-for-uri($filename)">
                        <p:pipe port="current" step="transform-batch"/>
                    </p:with-option>
                    <p:with-option name="tmp-dir" select="concat($tmp-dir,'/debug/',$diff)"/>
                    <p:with-option name="verbose" select="$verbose"/>
                </sg:save-debug>
            </p:when>

            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>

        <p:sink/>

    </p:for-each>


    <!-- We need an output so this will do -->
    <p:identity name="last">
        <p:input port="source">
            <p:pipe port="result" step="transform-batch"/>
        </p:input>
    </p:identity>


</p:declare-step>
