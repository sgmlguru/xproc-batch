<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:impl="urn:x-xspec:compile:xslt:impl"
    xmlns:test="http://www.jenitennison.com/xslt/unit-test"
    xmlns:x="http://www.jenitennison.com/xslt/xspec"
    xmlns:__x="http://www.w3.org/1999/XSL/TransformAliasAlias"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:pkg="http://expath.org/ns/pkg"
    name="xslt-test"
    version="3.0">
    
    <p:output port="result" sequence="true" serialization="map{'method': 'xml', 'indent': true()}"/>
    
    
    <p:xslt name="runxspec-xslt" version="2.0" template-name="x:main">
        <p:with-input port="source">
            <p:empty/>
        </p:with-input>
        <p:with-input port="stylesheet">
            <p:document href="04/tmp/xspec-tests/input.xml-step4-report.xsl"/>
        </p:with-input>
    </p:xslt>
    
    
</p:declare-step>