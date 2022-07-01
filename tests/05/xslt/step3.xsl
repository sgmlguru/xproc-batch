<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="param3A"/>
    <xsl:param name="param3B"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()" mode="STEP-3"/>
    </xsl:template>
    
    
    <xsl:template match="two" mode="STEP-3" priority="1">
        <three three="{$param3A}-{$param3B}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="STEP-3"/>
        </three>
    </xsl:template>
    
    
    <xsl:template match="node()" mode="STEP-3">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="STEP-3"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>