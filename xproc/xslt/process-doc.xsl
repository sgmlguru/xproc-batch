<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sg="http://www.sgmlguru/ns/xproc/steps"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs"
    version="3.0">
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>This is a preprocessing XSLT for saving the output of an XSLT step pipeline. It uses the secondary output to provide the document node and URL to the XProc pipeline calling it through <xd:pre>result-document</xd:pre>.</xd:p>
        </xd:desc>
    </xd:doc>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>This provides the input path, excluding a trailing /</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="input-base-uri"/>
    
    <xd:docdoc>>
        <xd:desc>
            <xd:p>Get rid of any protocol</xd:p>
        </xd:desc>
    </xd:docdoc>
    <xsl:variable
        name="local-input-base-uri"
        select="replace($input-base-uri,'^([a-z]+://)?(.+)$','$2')"/>
        
    <xd:doc>
        <xd:desc>
            <xd:p>This provides the output path, excluding a trailing /</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="output-base-uri"/>
    <xsl:variable
        name="local-output-base-uri"
        select="if (ends-with($output-base-uri,'/'))
                then ($output-base-uri)
                else ($output-base-uri || '/')"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This provides the input filename and path.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="input-file"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This provides the diff between the input filename and the base input path. In other words, we need to know if the input file is in a subdirectory of the base input dir and grab that subfolder.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="diff" select="substring-before(substring-after($input-file,$local-input-base-uri),tokenize($input-file,'/')[last()])"/>
    
    <xsl:variable name="filename">
        <xsl:value-of select="tokenize($input-file,'/')[last()]"/>
    </xsl:variable>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Save contents of ID transform</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="/">
        <xsl:result-document href="{concat($local-output-base-uri,$diff,'/',$filename)}">
            <xsl:apply-templates select="node()" mode="PREPROCESS_SAVE"/>
        </xsl:result-document>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Generic ID transform template</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="node()" mode="PREPROCESS_SAVE">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="PREPROCESS_SAVE"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>