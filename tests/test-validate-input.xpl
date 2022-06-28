<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:sgproc="http://www.sgmlguru.org/ns/xproc/steps"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    name="test-validate"
    type="sgproc:test-validate"
    version="3.0">
    
    <p:documentation>Validate files in an input directory. One fails, one succeedes.</p:documentation>
    
    
    <p:import href="../xproc/validate-input.xpl"/>
    
    <p:output port="result" serialization="map{'indent': true()}" sequence="true"/>
    
    
    <sgproc:validate-input>
        <p:with-option name="input-base-uri" select="'file:/home/ari/Documents/repos/xproc-batch/tests/01/'"/>
        <p:with-option name="validate" select="'true'"/>
    </sgproc:validate-input>
    
    
    
</p:declare-step>