<?xml version="1.0" encoding="UTF-8"?>
<sch:schema
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    
    <sch:pattern>
        <sch:title>Test para content</sch:title>
        <sch:rule context="p">
            <sch:assert test="normalize-space(text())!=''">Paragraphs shouldn't be empty.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern>
        <sch:title>Test for an attribute @three</sch:title>
        <sch:rule context="four">
            <sch:assert test="not(@three)">There is a three attribute.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>