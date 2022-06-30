<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:sgproc="http://www.sgmlguru.org/ns/xproc/steps"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    name="test-validate-with-schematron"
    type="sgproc:test-validate-with-schematron"
    version="3.0">
    
    <p:documentation>Validate files in an input directory against a Schematron.</p:documentation>
    
    
    <p:import href="../xproc/validate-with-schematron.xpl"/>
    
    <p:input port="sch">
        <p:document href="sch/test-para.sch"/>
    </p:input>
    
    <p:output port="result" serialization="map{'indent': true()}" sequence="true"/>
    
    
    <sgproc:validate-with-schematron>
        <p:with-option name="input-base-uri" select="resolve-uri('./03/')"/>
        <p:with-option name="validate" select="'true'"/>
    </sgproc:validate-with-schematron>
    
    
    
</p:declare-step>