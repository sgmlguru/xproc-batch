<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sg:save-debug"
    name="save-debug"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sg="http://www.sgmlguru/ns/xproc/steps"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    version="1.0">
    
    
    <p:documentation>
        <p>This XProc step constructs a list of the input XSLTs as defined by the XSLT manifest and merges them pairwise with the intermediate transform results from each step. It then saves these in a temporary folder, adding a subfolder per input document and with one file per XSLT step.</p>
    </p:documentation>
    
    
    <!-- Sequence of stylesheets loaded from manifest -->
    <p:input port="stylesheets" sequence="true">
        <p:documentation>
            <p>Sequence of XSLTs loaded from the manifest.</p>
        </p:documentation>
    </p:input>
    
    <!-- Sequence of intermediate step outputs -->
    <p:input port="intermediates" sequence="true">
        <p:documentation>
            <p>Sequence of intermediate XSLT step results.</p>
        </p:documentation>
    </p:input>
        
    <p:output port="result" sequence="true"/>
    
    
    <!-- Temp folder URI for saving for intermediate step results -->
    <p:option name="tmp-dir">
        <p:documentation>
            <p>Temp URI for saving the debug output.</p>
        </p:documentation>
    </p:option>
    
    <!-- Current input filename -->
    <p:option name="input-filename">
        <p:documentation>
            <p>Filename of the current input document, including suffix.</p>
        </p:documentation>
    </p:option>
    
    <!-- Enable disable verbose output -->
    <p:option name="verbose"/>
    
    <!-- Calabash extensions -->
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    
    <!-- XSLT step names from manifest, needed for relevant debug step names -->
    <p:for-each name="xslt-names">
        <p:iteration-source>
            <p:pipe port="stylesheets" step="save-debug"/>
        </p:iteration-source>
        
        <p:output port="result" primary="true" sequence="true"/>
        
        <p:template>
            <p:input port="source">
                <p:pipe port="current" step="xslt-names"/>
            </p:input>
            <p:input port="template">
                <p:inline>
                    <c:result>{$uri}</c:result>
                </p:inline>
            </p:input>
            <p:with-param name="uri" select="document-uri(/)"/>
        </p:template>
    </p:for-each>
    
    <!-- Wrap XSLT names and intermediate XSLT output in pairwise fashion -->
    <p:pack name="merge-name-content" wrapper="out">
        <p:input port="source">
            <p:pipe port="result" step="xslt-names"/>
        </p:input>
        <p:input port="alternate">
            <p:pipe port="intermediates" step="save-debug"/>
        </p:input>
    </p:pack>
    
    <!-- Intermediates output -->
    <p:for-each name="loop-debug">
        <p:output port="result" primary="true" sequence="true">
            <p:empty/>
        </p:output>
        
        <p:iteration-source>
            <p:pipe port="result" step="merge-name-content"/>
        </p:iteration-source>
        
        <!-- Current input filename, used for debug output path -->
        <p:variable name="filename" select="$input-filename"/>
        
        <!-- current XSLT step filename -->
        <p:variable name="xslt-name" select="tokenize(/out/c:result,'/')[last()]"/>
        
        <!-- Debug output, full path -->
        <p:variable name="debug-out" select="concat($tmp-dir,'/',$filename,'/',p:iteration-position(),'-',$xslt-name,'.xml')"/>
        
        <p:choose>
            <p:when test="$verbose='true'">
                <cx:message>
                    <p:with-option
                        name="message"
                        select="concat('Saving debug output to ', $debug-out)"/>
                </cx:message>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
        
        <p:store indent="false">
            <p:input port="source" select="/*:out/*[2]">
                <p:pipe port="current" step="loop-debug"/>
            </p:input>
            <p:with-option name="href" select="$debug-out"/>
        </p:store>
        
    </p:for-each>
    
    
</p:declare-step>