<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sg:xlsx2xml"
    name="xlsx2xml"
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
    
    
    <!-- XSLTs -->
    <p:input port="manifest">
        <p:documentation>
            <p>The manifest file listing the XSLT steps used by the transformation.</p>
        </p:documentation>
    </p:input>
    
    <!-- Optional XSLT params -->
    <p:input port="parameters" kind="parameter">
        <p:documentation>
            <p>Optional parameters fed to the pipelined XSLT.</p>
        </p:documentation>
    </p:input>
    
    <!-- Schematron -->
    <p:input port="sch">
        <p:documentation>
            <p>The Schematron used in the input and output validation.</p>
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
    
    <p:option name="include-filter" select="'(xlsx|XLSX)'">
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
    
    <!-- Reports -->
    <p:option name="reports-dir" required="true">
        <p:documentation>
            <p>URI for validation reports.</p>
        </p:documentation>
    </p:option>
    
    <!-- Output DOCTYPE SYSTEM identifier -->
    <p:option name="doctype-system" select="''">
        <p:documentation>
            <p>Output DTD SYSTEM identifier.</p>
        </p:documentation>
    </p:option>
    
    <!-- Output DOCTYPE PUBLIC identifier -->
    <p:option name="doctype-public" select="''">
        <p:documentation>
            <p>Output DTD PUBLIC identifier.</p>
        </p:documentation>
    </p:option>
    
    <!-- Enable verbose output -->
    <p:option name="verbose" select="'false'"/>
    
    <!-- Enable debug output (intermediate results on pipeline) -->
    <p:option name="debug" select="'false'"/>
    
    <!-- Enable output DTD validation -->
    <p:option name="dtd-validate-output" select="'false'"/>
    
    <!-- Enable output SCH validation -->
    <p:option name="sch-validate-output" select="'false'"/>
    
    <!-- Enable XSpec tests -->
    <p:option name="run-xspecs" select="'false'"/>
    
    <!-- Extract XML from docx archive -->
    <p:option name="extract-xlsx" select="'true'"/>
    
    <!-- XSpec Manifest URI -->
    <p:option name="xspec-manifest-uri"/>
    
    
    <!-- Calabash extensions -->
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
        
    <!-- Step for extracting stuff from docx -->
    <p:import href="http://www.sgmlguru/ns/xproc/steps/extract-from-xlsx.xpl"/>
    
    <!-- Step for validating and converting -->
    <p:import href="http://www.sgmlguru/ns/xproc/steps/validate-convert.xpl"/>
    
    
    <!-- Extract from the docx archive? -->
    <p:choose name="extract-archive">
        <p:when test="$extract-xlsx = 'true'">
            <!-- Extract from xlsx -->
            <sg:extract-from-xlsx name="extract">
                <p:with-option name="input-base-uri" select="$input-base-uri"/>
                <p:with-option name="output-base-uri" select="concat($tmp-dir,'/xml/')"/>
                <p:with-option name="include-filter" select="$include-filter"/>
                <p:with-option name="exclude-filter" select="$exclude-filter"/>
                <p:with-option name="verbose" select="$verbose"/>
                <p:with-option name="debug" select="$debug"/>
            </sg:extract-from-xlsx>
        </p:when>
        <p:otherwise>
            <p:identity>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    
    
    <!-- Convert -->
    <sg:validate-convert name="convert" cx:depends-on="extract-archive">
        <p:input port="manifest">
            <p:pipe port="manifest" step="xlsx2xml"/>
        </p:input>
        <p:input port="parameters">
            <p:pipe port="parameters" step="xlsx2xml"/>
        </p:input>
        <p:input port="sch">
            <p:pipe port="sch" step="xlsx2xml"/>
        </p:input>
        <p:with-option name="input-base-uri" select="concat($tmp-dir,'/xml/')"/>
        <p:with-option name="output-base-uri" select="concat($output-base-uri,'/')"/>
        <p:with-option name="tmp-dir" select="$tmp-dir"/>
        <p:with-option name="reports-dir" select="$reports-dir"/>
        <p:with-option name="doctype-system" select="$doctype-system"/>
        <p:with-option name="doctype-public" select="$doctype-public"/>
        <p:with-option name="verbose" select="$verbose"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="xspec-manifest-uri" select="$xspec-manifest-uri"/>
        <p:with-option name="run-xspecs" select="$run-xspecs"/>
    </sg:validate-convert>
    
    
    
    <!-- We need an output so this will do -->
    <p:identity name="last">
        <p:input port="source"/>
    </p:identity>
    
    
</p:declare-step>
