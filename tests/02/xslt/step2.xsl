<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()" mode="STEP-2"/>
    </xsl:template>
    
    
    <xsl:template match="one" mode="STEP-2" priority="1">
        <two>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="STEP-2"/>
        </two>
    </xsl:template>
    
    
    <xsl:template match="node()" mode="STEP-2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="STEP-2"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>