<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:sgproc="http://www.sgmlguru.org/ns/xproc/steps"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    name="test-validate-with-schematron"
    type="sgproc:test-validate-with-schematron"
    version="3.0">
    
    <p:documentation>Validate files in an input directory against a Schematron.</p:documentation>
    
    
    <p:import href="../xproc/run-xspecs.xpl"/>
    
    <p:input port="sch">
        <p:document href="sch/test-para.sch"/>
    </p:input>
    
    <p:output port="result" serialization="map{'indent': true()}" sequence="true"/>
    
    
    <sgproc:run-xspecs>
        <p:with-option name="xspec-manifest-uri" select="resolve-uri('./04/test-xspec-manifest.xml')"/>
        <p:with-option name="tmp-folder-uri" select="resolve-uri('./04/tmp/')"/>
        
        <p:with-option name="run-xspecs" select="'true'"/>
    </sgproc:run-xspecs>
    
</p:declare-step>