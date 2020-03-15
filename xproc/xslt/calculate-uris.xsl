<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    
    <xsl:template match="c:file">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            
            <xsl:attribute name="uri">
                <xsl:for-each select="ancestor-or-self::*">
                    <xsl:value-of select="@xml:base"/>
                </xsl:for-each>
            </xsl:attribute>
            
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>