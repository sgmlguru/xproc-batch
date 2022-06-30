<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sgproc:run-xspecs"
    name="run-xspecs"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sgproc="http://www.sgmlguru.org/ns/xproc/steps"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    xmlns:x="http://www.jenitennison.com/xslt/xspec"
    version="3.0">
    
    <!-- XSLT to generate instance XSpecs -->
    <p:input port="xspec2instance">
        <p:document href="xslt/generate-instance-xspecs.xsl"/>
    </p:input>
    
    <!-- XSLT to convert XSpec to XSLT -->
    <p:input port="xspec2xsl">
        <p:document href="../xspec/src/compiler/generate-xspec-tests.xsl"/>
    </p:input>
    
    <!-- XSLT to convert XSpec report to HTML -->
    <p:input port="xspec-report2html">
        <p:document href="../xspec/src/reporter/format-xspec-report.xsl"/>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:empty/>
    </p:output>
    
    <!-- Params -->
    <p:option name="params" required="false" as="xs:string*"/>
    
    <!-- XSpec Manifest file -->
    <p:option
        name="xspec-manifest-uri"/>
    
    <!-- Temp location -->
    <p:option
        name="tmp-folder-uri"/>
    
    <!-- Run XSpecs? -->
    <p:option name="run-xspecs" select="'false'"/>
    
    
    
    <!-- Run XSpecs? -->
    <p:choose name="run">
        <p:when test="$run-xspecs='true'">
            <!--<cx:message>
                <p:with-option name="message" select="concat('Temp folder is ',$tmp-folder-uri)"/>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </cx:message>-->
            
            <p:identity message="{concat('Temp folder is ',$tmp-folder-uri)}"/>
            
            <!--<cx:message>
                <p:with-option name="message" select="concat('XSpec manifest URI is ',$xspec-manifest-uri)"/>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </cx:message>-->
            
            <p:identity message="{concat('XSpec manifest URI is ',$xspec-manifest-uri)}"/>
            
            <!-- Generate instance XSpecs -->
            <p:xslt
                name="generate-xspec-instances"
                parameters="map{'tmp-folder': $tmp-folder-uri,
                                'xspec-manifest-uri': $xspec-manifest-uri}">
                <p:with-input port="source">
                    <p:inline>
                        <empty/>
                    </p:inline>
                </p:with-input>
                <p:with-input port="stylesheet">
                    <p:pipe port="xspec2instance" step="run-xspecs"/>
                </p:with-input>
            </p:xslt>
            
            
            <!-- Nothing interesting on the primary port so throw it away -->
            <p:sink/>
            
            
            <!-- Generate XSLTs from the instance XSpecs available on the secondary port -->
            <p:for-each name="generate-xslt-tests">
                
                <p:with-input select=".">
                    <p:pipe port="secondary" step="generate-xspec-instances"/>
                </p:with-input>
                
                <p:output port="result" sequence="true">
                    <p:empty/>
                </p:output>
                
                <!-- The current instance XSpec's URI from the XSLT secondary (result-document) port -->
                <p:variable name="current-path" select="p:base-uri()"/>
                
                <p:identity
                    name="iteration-source"
                    message="{if ($run-xspecs='true')
                    then (concat('Running XSpec tests in ',$current-path))
                    else ()}"/>
                
                <!--<cx:message>
                    <p:with-option
                        name="message"
                        select="if ($run-xspecs='true')
                        then (concat('Running XSpec tests in ',$current-path))
                        else ()"/>
                </cx:message>-->
                
                <!-- Save the instance XSpecs for debug purposes -->
                <p:store serialization="map{'method': 'xml'}">
                    <p:with-option name="href" select="$current-path"/>
                </p:store>
                
                <!-- Convert the current instance XSpec to XSLT -->
                <p:xslt name="xspec2xsl">
                    <p:with-input port="source">
                        <p:pipe port="result" step="iteration-source"/>
                    </p:with-input>
                    <p:with-input port="stylesheet">
                        <p:pipe port="xspec2xsl" step="run-xspecs"/>
                    </p:with-input>
                    <p:with-option name="parameters" select=".">
                        <p:pipe port="params" step="run-xspecs"/>
                    </p:with-option>
                </p:xslt>
                
                <!-- Run the XSLT -->
                <p:xslt name="runxspec-xslt">
                    <p:with-input port="source">
                        <p:empty/>
                    </p:with-input>
                    <p:with-input port="stylesheet">
                        <p:pipe port="result" step="xspec2xsl"/>
                    </p:with-input>
                    <p:with-option name="template-name" select="'x:main'"/>
                    <p:with-option name="parameters" select=".">
                        <p:pipe port="params" step="run-xspecs"/>
                    </p:with-option>
                </p:xslt>
                
                <!-- Convert the XML reports to HTML -->
                <p:xslt name="xspec-xml2html">
                    <p:with-input port="source"/>
                    <p:with-input port="stylesheet">
                        <p:pipe port="xspec-report2html" step="run-xspecs"/>
                    </p:with-input>
                    <p:with-option name="parameters" select=".">
                        <p:pipe port="params" step="run-xspecs"/>
                    </p:with-option>
                </p:xslt>
                
                <!-- Save the HTML -->
                <p:store serialization="map{'method': 'xml'}">
                    <p:with-option name="href" select="replace($current-path,'\.xspec','-report.xhtml')"/>
                </p:store>
                
            </p:for-each>
            
            <p:sink/>
            
        </p:when>
        
        <p:otherwise>
            <p:sink>
                <p:with-input port="source">
                    <p:empty/>
                </p:with-input>
            </p:sink>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>