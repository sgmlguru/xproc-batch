<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:sgproc="http://www.sgmlguru.org/ns/xproc/steps"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    name="test-validate-with-schematron"
    type="sgproc:test-validate-convert"
    version="3.0">
    
    <p:documentation>Test validate-convert step filters to include only XML files and filter on root element "doc"</p:documentation>
    
    
    <p:import href="../xproc/validate-convert.xpl"/>
    
    <p:output port="result" serialization="map{'indent': true()}" sequence="true"/>
    
    
    <sgproc:validate-convert>
        <p:with-input port="manifest" href="05/test-manifest.xml"/>
        <p:with-input port="sch" href="sch/test-para.sch"/>
        <p:with-option name="input-base-uri" select="resolve-uri('./05/sources')"/>
        <p:with-option name="include-filter" select="'\.xml'"/>
        <p:with-option name="output-base-uri" select="resolve-uri('./05/tmp/out')"/>
        <p:with-option name="reports-dir" select="resolve-uri('./05/tmp/reports')"/>
        <p:with-option name="tmp-dir" select="resolve-uri('./05/tmp')"/>
        <p:with-option name="root-filter" select="'doc'"/>
        <p:with-option name="xspec-manifest-uri" select="resolve-uri('./04/test-xspec-manifest.xml')"/>
        <p:with-option name="sch-validate-output" select="'false'"/>
        <p:with-option name="debug" select="'true'"/>
        <!--<p:with-option name="run-xspecs" select="'false'"/>-->
    </sgproc:validate-convert>
    
</p:declare-step>