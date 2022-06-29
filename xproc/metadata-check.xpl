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
    
    <!-- XProc Tools -->
    <p:import href="../xproc-tools/xproc/recursive-directory-list.xpl"/>
    <!-- http://xml.corbas.co.uk/xml/xproc-tools/recursive-directory-list.xpl -->
    <p:import href="../xproc-tools/xproc/load-sequence-from-file.xpl"/>
    <!-- http://xml.corbas.co.uk/xml/xproc-tools/load-sequence-from-file.xpl -->
    <p:import href="../xproc-tools/xproc/threaded-xslt.xpl"/>
    <!-- http://xml.corbas.co.uk/xml/xproc-tools/threaded-xslt.xpl -->
    
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

    <p:option name="include-filter" select="'\.xml'" required="false">
        <p:documentation>
            <p>The file suffix of the input files to be converted. Leaving this empty will attempt to convert everything, so don't do it unless you know what you're doing.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="exclude-filter" required="false"/>

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

    
    


    <!-- Load the XSLTs in the manifest as a sequence -->
    <ccproc:load-sequence-from-file
        name="manifest-sequence">
        <p:with-input port="source">
            <p:pipe port="manifest" step="batch-convert"/>
        </p:with-input>
    </ccproc:load-sequence-from-file>

    
    
    
    <p:wrap-sequence name="merge-load" wrapper="test:sequence">
        <p:with-input port="source">
            <p:pipe port="result" step="manifest-sequence"/>
        </p:with-input>
    </p:wrap-sequence>


</p:declare-step>
