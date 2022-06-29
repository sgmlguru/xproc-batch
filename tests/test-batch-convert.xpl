<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:sgproc="http://www.sgmlguru.org/ns/xproc/steps"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    name="test-batch-convert"
    type="sgproc:test-batch-convert"
    version="3.0">
    
    <p:documentation></p:documentation>
    
    <p:import href="../xproc/batch-convert.xpl"/>
    
    
    <p:input port="manifest">
        <p:document href="02/test-manifest.xml"/>
    </p:input>
    
    <p:output port="result" serialization="map{'indent': true()}" sequence="true"/>
    
    
    <sgproc:batch-convert>
        <p:with-input port="manifest">
            <p:pipe port="manifest" step="test-batch-convert"/>
        </p:with-input>
        <p:with-option name="input-base-uri" select="resolve-uri('./02/sources/')"/>
        <p:with-option name="output-base-uri" select="resolve-uri('./tmp/out')"/>
        <p:with-option name="validate" select="false()"/>
        <p:with-option name="debug" select="'false'"/>
    </sgproc:batch-convert>
    
    
</p:declare-step>