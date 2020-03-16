<xsl:stylesheet
    xmlns:data="http://www.corbas.co.uk/ns/transforms/data"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="data:meta">
        <xsl:element name="param">
            <xsl:copy-of select="@*"/>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>