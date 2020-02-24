<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="#all"
    version="2.0">
    
    
    <!-- This tests the existence of XInclude targets -->
    
    
    <xsl:output method="xml" indent="yes"/>
    
    
    <xsl:template match="/*">
        <xsl:variable name="xincludes">
            <xincludes href="{base-uri(.)}">
                <xsl:apply-templates select=".//xi:include"/>
            </xincludes>
        </xsl:variable>
        
        <modules href="{$xincludes/*/@href}">
            <xsl:for-each select="$xincludes//module">
                <xsl:sort select="@valid-link"/>
                <xsl:copy-of select="." copy-namespaces="no"/>
            </xsl:for-each>
        </modules>
        
    </xsl:template>
    
    
    <xsl:template match="xi:include">
        <module>
            <xsl:attribute name="href" select="@href"/>
            
            <xsl:choose>
                <xsl:when test="doc-available(@href)">
                    <xsl:attribute name="valid-link" select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="valid-link" select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
            
        </module>
    </xsl:template>
    
    
</xsl:stylesheet>
