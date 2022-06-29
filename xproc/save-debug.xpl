<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sgproc:save-debug"
    name="save-debug"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sgproc="http://www.sgmlguru.org/ns/xproc/steps"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    version="3.0">
    
    
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
    <p:option name="verbose" required="false" select="'false'"/>
    
    
    <!-- XSLT filenames -->
    <p:json-merge name="merged">
        <p:with-input select="document-uri(/)">
            <p:pipe step="save-debug" port="stylesheets"/>
        </p:with-input>
        <p:documentation>The input is JSON in need of merging</p:documentation>
    </p:json-merge>
    
    <!-- Cast to XML -->
    <p:cast-content-type name="caster" content-type="application/xml"/>
    
    <!-- Remove wrapper to produce a sequence -->
    <p:filter name="filter" select="//*:string"/>
    
    
    <!-- Wrap XSLT names and intermediate XSLT output in pairwise fashion -->
    <p:pack name="merge-name-content" wrapper="out">
        <p:with-input port="source">
            <p:pipe port="result" step="filter"/>
        </p:with-input>
        <p:with-input port="alternate">
            <p:pipe port="intermediates" step="save-debug"/>
        </p:with-input>
    </p:pack>
    
    
    <!-- Intermediates output -->
    <p:for-each name="loop-debug">
        <p:output port="result" primary="true" sequence="true">
            <p:empty/>
        </p:output>
        
        <!-- Current input filename, used for debug output path -->
        <p:variable name="filename" select="$input-filename"/>
        
        <!-- current XSLT step filename -->
        <p:variable name="xslt-name" select="tokenize(/out/*:string/text(),'/')[last()]"/>
        
        <!-- Debug output, full path -->
        <p:variable name="debug-out" select="concat($tmp-dir,'/',$filename,'/',p:iteration-position(),'-',$xslt-name,'.xml')"/>
        
        <p:choose>
            <p:when test="$verbose='true'">
                <p:identity message="{concat('Saving debug output to ', $debug-out)}"/>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
        
        <p:store serialization="map{'indent': false()}">
            <p:with-input port="source" select="/*:out/*[2]">
                <p:pipe port="current" step="loop-debug"/>
            </p:with-input>
            <p:with-option name="href" select="$debug-out"/>
        </p:store>
        
    </p:for-each>
    
    
</p:declare-step>