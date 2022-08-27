<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sgproc:batch-convert"
    name="batch-convert"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:sgproc="http://www.sgmlguru.org/ns/xproc/steps"
    xmlns:fc="http://educations.com/XmlImport"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:test="http://www.corbas.co.uk/ns/test"
    version="3.0">
    
    <p:documentation>This converts an input file using a manifest listing XSLTs, optionally outputting debug output from each step.</p:documentation>
    
    <!-- XProc Tools -->
    <p:import href="http://xml.corbas.co.uk/xml/xproc-tools/xproc/recursive-directory-list.xpl"/>
    <p:import href="http://xml.corbas.co.uk/xml/xproc-tools/xproc/load-sequence-from-file.xpl"/>
    <p:import href="http://xml.corbas.co.uk/xml/xproc-tools/xproc/threaded-xslt.xpl"/>
    
    <!-- Step for saving debug output -->
    <p:import href="../xproc/save-debug.xpl"/>
    <!-- http://www.sgmlguru/ns/xproc/steps/save-debug.xpl -->
    

    <!-- XSLTs from manifest -->
    <p:input port="manifest">
        <p:documentation>
            <p>The manifest file listing the XSLT steps used by the transformation.</p>
        </p:documentation>
    </p:input>
    
    <p:output port="result" sequence="true" serialization="map{'indent': true()}"/>
    
    
    <!-- Optional XSLT params -->
    <p:option name="parameters" required="false" as="xs:string*">
        <p:documentation>
            <p>Optional parameters for the pipelined XSLT.</p>
        </p:documentation>
    </p:option>
    
    <!-- Input path -->
    <p:option name="input-base-uri">
        <p:documentation>
            <p>Source document(s) URI. Every document ending with suffix <em>$include-filter</em> in this folder and its subfolders is transformed.</p>
        </p:documentation>
    </p:option>

    <p:option name="include-filter" as="xs:string?" required="false">
        <p:documentation>
            <p>The file suffix of the input files to be converted. Leaving this empty will attempt to convert everything, so don't do it unless you know what you're doing.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="exclude-filter" as="xs:string?" required="false"/>
    
    <p:option name="root-filter" required="false" select="'[\W\w]*'" as="xs:string"/>

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
    <p:option name="doctype-system" required="false" as="xs:string" select="''">
        <p:documentation>
            <p>Output DTD SYSTEM identifier.</p>
        </p:documentation>
    </p:option>

    <!-- Output DOCTYPE PUBLIC identifier -->
    <p:option name="doctype-public" required="false" as="xs:string" select="''">
        <p:documentation>
            <p>Output DTD PUBLIC identifier.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="validate" required="false" select="false()" as="xs:boolean"/>

    <!-- Enable verbose output -->
    <p:option name="verbose" required="false" select="'true'"/>

    <!-- Enable debug output (intermediate results on pipeline) -->
    <p:option name="debug" select="'false'"/>

    
    <!-- Create output dir -->
    <p:file-mkdir name="mkdir">
        <p:with-option name="href" select="$output-base-uri"/>
    </p:file-mkdir>
    
    <!-- Get rid of the mkdir output -->
    <p:sink/>


    <!-- Input documents list -->
    <sgproc:recursive-directory-list name="source-files">
        <p:with-option name="path" select="$input-base-uri"/>
        <!-- Add @uri to c:file elements -->
        <p:with-option name="resolve" select="'true'"/>
        <p:with-option name="include-filter" select="$include-filter"/>
        <p:with-option name="exclude-filter" select="$exclude-filter"/>
    </sgproc:recursive-directory-list>
    
    <!-- URI-encode the directory listing -->
    <p:xslt name="uri-encoded-sources">
        <p:with-input port="source">
            <p:pipe port="result" step="source-files"/>
        </p:with-input>
        <p:with-input port="stylesheet">
            <p:document href="xslt/uri-encode-dir-listing.xsl"/>
        </p:with-input>
    </p:xslt>

    <p:sink/>


    <!-- Load the XSLTs in the manifest as a sequence -->
    <ccproc:load-sequence-from-file
        name="manifest-sequence">
        <p:with-input port="source">
            <p:pipe port="manifest" step="batch-convert"/>
        </p:with-input>
    </ccproc:load-sequence-from-file>

    <p:sink/>


    <!-- Transform documents -->
    <p:for-each name="transform-batch">
        
        <p:with-input select="//c:file[matches(name(doc(@uri)/*), '^' || $root-filter || '$')]">
            <p:pipe port="result" step="uri-encoded-sources"/>
        </p:with-input>
        
        <p:output port="result" primary="true" sequence="true">
            <p:empty/>
        </p:output>
        
        
        <p:variable name="uri" select="xs:string(/c:file/@uri)"/>
        
        <p:variable name="filename" select="tokenize($uri,'/')[last()]"/>
        
        <p:variable name="path" select="substring-before($uri,$filename)"/>
        
        <p:variable name="current-file" select="concat($path,encode-for-uri($filename))"/>
        
        <p:variable name="diff" select="substring-before(substring-after($uri,$input-base-uri),tokenize($uri,'/')[last()])">
            <p:documentation>
                <p>This is the diff between the base input URI and any subfolders the input files may be placed in.</p>
            </p:documentation>
        </p:variable>
        
        
        <p:variable name="root-name" select="name(doc($uri)/*)"/>
        <p:identity message="Filtering on root expression: {$root-name}"/>
        

        <p:choose>
            <p:when test="$verbose='true'">
                <p:identity message="{concat('Transforming ', $uri)}"/>
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
            <p:with-input port="source">
                <p:pipe port="result" step="load-document"/>
            </p:with-input>
            <p:with-input port="stylesheets">
                <p:pipe port="result" step="manifest-sequence"/>
            </p:with-input>
            <p:with-option name="parameters" select="$parameters"/>
            <p:with-option name="verbose" select="$verbose"/>
        </ccproc:threaded-xslt>

        <!-- This gives us an ID transform and href on secondary output (result-document in XSLT); the XSLT handles filenaming -->
        <p:xslt name="process-output">
            <p:with-input port="source">
                <p:pipe port="result" step="conv"/>
            </p:with-input>
            <p:with-input port="stylesheet">
                <p:document href="xslt/process-doc.xsl"/>
            </p:with-input>
            <p:with-option
                name="parameters"
                select="map{'input-base-uri': $input-base-uri,
                'input-file': $uri,
                'output-base-uri': $output-base-uri}">
                <p:pipe port="current" step="transform-batch"/>
            </p:with-option>
        </p:xslt>

        <!-- Get rid of the primary output; we only want the secondary -->
        <p:sink/>


        <!-- Store the secondary output from transform (this is the actual output document) -->
        <p:for-each name="store-output">
            <p:with-input>
                <p:pipe port="secondary" step="process-output"/>
            </p:with-input>

            <p:variable name="href" select="document-uri(/)">
                <p:pipe port="secondary" step="process-output"/>
            </p:variable>

            <p:choose>
                <p:when test="$verbose='true'">
                    <p:identity message="{concat('Saving output to ', $href)}"/>
                </p:when>
                <p:otherwise>
                    <p:identity/>
                </p:otherwise>
            </p:choose>
            
            
            <p:choose>
                
                <!-- If no DTD -->
                <p:when test="$doctype-system = '' and $doctype-public = ''">
                    <p:store
                        message="Saving without DOCTYPE - no PUBLIC or SYSTEM identifier provided"
                        serialization="map{'encoding': 'UTF-8',
                        'omit-xml-declaration': false(),
                        'indent': false()}">
                        <p:with-input port="source">
                            <p:pipe port="current" step="store-output"/>
                        </p:with-input>
                        <p:with-option name="href" select="document-uri(/)">
                            <p:pipe port="current" step="store-output"/>
                        </p:with-option>
                    </p:store>
                </p:when>
                
                <!-- If DTD -->
                <p:otherwise>
                    <p:store
                        message="Saving with PUBLIC ID {$doctype-public} and SYSTEM ID {$doctype-system}"
                        serialization="map{'indent': false(),
                        'doctype-public': $doctype-public,
                        'doctype-system': $doctype-system,
                        'cdata-section-elements': fc:field}">
                        <p:with-input port="source">
                            <p:pipe port="current" step="store-output"/>
                        </p:with-input>
                        <p:with-option name="href" select="document-uri(/)">
                            <p:pipe port="current" step="store-output"/>
                        </p:with-option>
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
                
                <p:file-mkdir>
                    <p:with-option name="href" select="concat($tmp-dir,'/debug/',$diff,'/',encode-for-uri($filename))"/>
                </p:file-mkdir>
                
                <p:identity message="{concat($tmp-dir,'/debug/',$diff,'/',encode-for-uri($filename))}">
                    <p:with-input></p:with-input>
                </p:identity>

                <p:store serialization="map{'indent': false()}">
                    <p:with-input port="source">
                        <p:pipe port="result" step="orig-file"/>
                    </p:with-input>
                    <p:with-option
                        name="href"
                        select="concat($tmp-dir,'/debug/',$diff,'/',encode-for-uri($filename),'/0-',encode-for-uri($filename))">
                        <p:pipe port="current" step="transform-batch"/>
                    </p:with-option>
                </p:store>

                <sgproc:save-debug>
                    <p:with-input port="stylesheets">
                        <p:pipe port="result" step="manifest-sequence"/>
                    </p:with-input>
                    <p:with-input port="intermediates">
                        <p:pipe port="intermediates" step="conv"/>
                    </p:with-input>
                    <p:with-option name="input-filename" select="encode-for-uri($filename)">
                        <p:pipe port="current" step="transform-batch"/>
                    </p:with-option>
                    <p:with-option name="tmp-dir" select="concat($tmp-dir,'/debug/',$diff)"/>
                    <p:with-option name="verbose" select="$verbose"/>
                </sgproc:save-debug>
            </p:when>

            <p:otherwise>
                <p:identity>
                    <p:with-input port="source">
                        <p:empty/>
                    </p:with-input>
                </p:identity>
            </p:otherwise>
        </p:choose>

        <p:sink/>

    </p:for-each>

</p:declare-step>
