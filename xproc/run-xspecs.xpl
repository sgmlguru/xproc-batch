<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sg:run-xspecs"
    name="run-xspecs"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sg="http://www.sgmlguru/ns/xproc/steps"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    xmlns:x="http://www.jenitennison.com/xslt/xspec"
    version="1.0">
    
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
    
    <!-- Params -->
    <p:input port="params" kind="parameter"/>
    
    <p:output port="result" sequence="true">
        <p:empty/>
    </p:output>
    
    <!-- XSpec Manifest file -->
    <p:option
        name="xspec-manifest-uri"/>
    
    <!-- Temp location -->
    <p:option
        name="tmp-folder-uri"/>
    
    <!-- Run XSpecs? -->
    <p:option name="run-xspecs" select="'false'"/>
    
    
    <!-- Calabash extensions -->
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    
    <!-- Run XSpecs? -->
    <p:choose name="run">
        <p:when test="$run-xspecs='true'">
            <cx:message>
                <p:with-option name="message" select="concat('Temp folder is ',$tmp-folder-uri)"/>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </cx:message>
            
            <cx:message>
                <p:with-option name="message" select="concat('XSpec manifest URI is ',$xspec-manifest-uri)"/>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </cx:message>
            
            <!-- Generate instance XSpecs -->
            <p:xslt name="generate-xspec-instances">
                <p:input port="source">
                    <p:inline>
                        <empty/>
                    </p:inline>
                </p:input>
                <p:input port="stylesheet">
                    <p:pipe port="xspec2instance" step="run-xspecs"/>
                </p:input>
                <p:with-param name="tmp-folder" select="$tmp-folder-uri"/>
                <p:with-param name="xspec-manifest-uri" select="$xspec-manifest-uri"/>
            </p:xslt>
            
            
            <!-- Nothing interesting on the primary port so throw it away -->
            <p:sink/>
            
            
            <!-- Generate XSLTs from the instance XSpecs available on the secondary port -->
            <p:for-each name="generate-xslt-tests">
                
                <p:iteration-source>
                    <p:pipe port="secondary" step="generate-xspec-instances"/>
                </p:iteration-source>
                
                <p:output port="result" sequence="true">
                    <p:empty/>
                </p:output>
                
                <!-- The current instance XSpec's URI from the XSLT secondary (result-document) port -->
                <p:variable name="current-path" select="p:base-uri()"/>
                
                <p:identity name="iteration-source"/>
                
                <cx:message>
                    <p:with-option
                        name="message"
                        select="if ($run-xspecs='true')
                        then (concat('Running XSpec tests in ',$current-path))
                        else ()"/>
                </cx:message>
                
                <!-- Save the instance XSpecs for debug purposes -->
                <p:store method="xml">
                    <p:with-option name="href" select="$current-path"/>
                </p:store>
                
                <!-- Convert the current instance XSpec to XSLT -->
                <p:xslt name="xspec2xsl">
                    <p:input port="source">
                        <p:pipe port="result" step="iteration-source"/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:pipe port="xspec2xsl" step="run-xspecs"/>
                    </p:input>
                    <p:input port="parameters">
                        <p:pipe port="params" step="run-xspecs"/>
                    </p:input>
                </p:xslt>
                
                <!-- Run the XSLT -->
                <p:xslt name="runxspec-xslt">
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:pipe port="result" step="xspec2xsl"/>
                    </p:input>
                    <p:with-option name="template-name" select="'x:main'"/>
                    <p:input port="parameters">
                        <p:pipe port="params" step="run-xspecs"/>
                    </p:input>
                </p:xslt>
                
                <!-- Convert the XML reports to HTML -->
                <p:xslt name="xspec-xml2html">
                    <p:input port="source"/>
                    <p:input port="stylesheet">
                        <p:pipe port="xspec-report2html" step="run-xspecs"/>
                    </p:input>
                    <p:input port="parameters">
                        <p:pipe port="params" step="run-xspecs"/>
                    </p:input>
                </p:xslt>
                
                <!-- Save the HTML -->
                <p:store 
                    method="xml">
                    <p:with-option name="href" select="replace($current-path,'\.xspec','-report.xhtml')"/>
                </p:store>
                
            </p:for-each>
            
            <p:sink/>
            
        </p:when>
        
        <p:otherwise>
            <p:sink>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:sink>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>