<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sg="http://www.sgmlguru/ns/xproc/steps"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    xmlns:pxp="http://exproc.org/proposed/steps"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    
    <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    
    <xsl:template match="c:file|c:directory">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="@uri | @name">
        
        <!-- Some paths are absolute but without a protocol -->
        <xsl:variable name="start" select="if (starts-with(.,'/')) then ('/') else ('')"/>
        
        <!-- Some paths have a protocol -->
        <xsl:variable name="protocol">
            <xsl:analyze-string select="." regex="^([a-z]+:)(/+)">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                    <xsl:value-of select="regex-group(2)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        
        
        <xsl:attribute name="{name(.)}">
            
            <!-- This will be empty if there is a protocol -->
            <xsl:value-of select="$start"/>
            
            <xsl:for-each select="tokenize(.,'/')">
                
                <xsl:choose>
                    <xsl:when test=".!='' and not(contains(.,'%'))">
                        <xsl:choose>
                            <xsl:when test="$protocol != '' and position() = 1">
                                <xsl:value-of select="$protocol"/>
                            </xsl:when>
                            <xsl:when test="$protocol = '' and position() = 1 and position() != last()">
                                <xsl:value-of select="encode-for-uri(.)"/>
                                <xsl:value-of select="'/'"/>
                            </xsl:when>
                            <xsl:when test="position() != 1 and position() != last()">
                                <xsl:value-of select="encode-for-uri(.)"/>
                                <xsl:value-of select="'/'"/>
                            </xsl:when>
                            <xsl:when test="position() = last()">
                                <xsl:value-of select="encode-for-uri(.)"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test=".!=''">
                        <xsl:choose>
                            <xsl:when test="$protocol != '' and position() = 1">
                                <xsl:value-of select="$protocol"/>
                            </xsl:when>
                            <xsl:when test="$protocol = '' and position() = 1 and position() != last()">
                                <xsl:value-of select="replace(.,' ','%20')"/>
                                <xsl:value-of select="'/'"/>
                            </xsl:when>
                            <xsl:when test="position() != 1 and position() != last()">
                                <xsl:value-of select="replace(.,' ','%20')"/>
                                <xsl:value-of select="'/'"/>
                            </xsl:when>
                            <xsl:when test="position() = last()">
                                <xsl:value-of select="replace(.,' ','%20')"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
                
            </xsl:for-each>
            
        </xsl:attribute>
        
    </xsl:template>
    
    
    <xsl:template match="@*">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    
</xsl:stylesheet>