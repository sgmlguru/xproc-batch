<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:sgproc="http://www.sgmlguru.org/ns/xproc/steps"
    xmlns:x="http://www.jenitennison.com/xslt/xspec"
    exclude-result-prefixes="xs xd"
    version="2.0">
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>This XSLT generates instance XSpec files, based on an XSLT manifest and an XSpec manifest. It requires the debug output (intermediate steps) from the pipeline. For an input file <xd:pre>test.xml</xd:pre>, the debug output is assumed to use the following naming convention:</xd:p>
            <xd:pre>tmp/test.xml:
total 16K
-rw-rw-r-- 1 ari ari 308 May  3 13:38 0-step1.xsl.xml
-rw-rw-r-- 1 ari ari 308 May  3 13:38 1-step1.xsl.xml
-rw-rw-r-- 1 ari ari 304 May  3 13:38 2-step2.xsl.xml
-rw-rw-r-- 1 ari ari 300 May  3 13:38 3-step3.xsl.xml
-rw-rw-r-- 1 ari ari 287 May  3 13:38 4-step4.xsl.xml</xd:pre>
            <xd:p>Here, <xd:pre>0-step1.xsl.xml</xd:pre> is a copy of the unchanged input file. Similarly, the last debug file, <xd:pre>4-step4.xsl.xml</xd:pre> is identical to the resulting output from the last pipeline step.</xd:p>
        </xd:desc>
    </xd:doc>
    
    
    <xsl:param
        name="tmp-folder"/>
    
    <xsl:variable
        name="tmp-file-list"
        select="for $file in collection(concat($tmp-folder,'?select=*.xml;recurse=yes')) return document-uri($file)"/>
    
    <!-- Temp (intermediate) file listing; needs to be sorted because we rely on step ordering later -->
    <xsl:variable name="uris">
        <uris>
            <xsl:for-each select="$tmp-file-list">
                <xsl:sort select="."/>
                <uri>
                    <xsl:value-of select="."/>
                </uri>
            </xsl:for-each>
        </uris>
    </xsl:variable>
    
    <!-- Input XSpec manifest URI; may be a relative path -->
    <xsl:param
        name="xspec-manifest-uri"/>
    
    <!-- Manifest -->
    <xsl:variable
        name="xspec-manifest"
        select="doc($xspec-manifest-uri)"/>
    
    <!-- Manifest filename w/o path -->
    <xsl:variable
        name="manifest-name"
        select="tokenize($xspec-manifest-uri,'/')[last()]"/>
    
    <!-- Since the XSpec manifest URI may be a relative path, we need to find out its actual absolute path -->
    <xsl:variable
        name="manifest-path"
        select="substring-before(document-uri($xspec-manifest),concat('/',$manifest-name))"/>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Generates a variable listing the output XSpecs to be produced, with their inputs, outputs, XSLT, and focus. It then loops through each file (<xd:pre>pair</xd:pre>) to generate the instance XSpecs.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="/">
        
        <xsl:variable name="xspecs">
            <xspecs>
                
                <xsl:for-each select="$xspec-manifest//sgproc:test">
                    <xsl:variable name="test" select="."/>
                    <xsl:variable name="xslt" select="tokenize($test/@xslt,'/')[last()]"/>
                    <xsl:variable name="focus" select="$test/@focus"/>
                    
                    <xspec href="{concat($manifest-path,'/',@xspec)}" xslt="{$test/@xslt}">
                        <xsl:for-each select="$uris//uri">
                            <xsl:variable name="uri" select="text()"/>
                            
                            <xsl:variable name="out-in">
                                <xsl:analyze-string select="text()" regex="{concat('/','([1-9][0-9]*)\-(',$xslt,'\.xml)')}">
                                    <xsl:matching-substring>
                                        
                                        <!-- The ordinals before the intermediate files -->
                                        <xsl:variable name="current-number" select="number(regex-group(1))"/>
                                        <xsl:variable name="previous-number" select="$current-number - 1"/>
                                        
                                        <pair>
                                            
                                            <!-- This is the current input XML filename, NOT an intermediate XML filename -->
                                            <xsl:variable name="input-xml-name">
                                                <xsl:analyze-string select="$uri" regex="/([^/]+)/[^/]+$">
                                                    <xsl:matching-substring>
                                                        <xsl:value-of select="regex-group(1)"/>
                                                    </xsl:matching-substring>
                                                </xsl:analyze-string>
                                            </xsl:variable>
                                            
                                            <!-- The input filename before the pipeline, used to name the generated XSpec -->
                                            <file>
                                                <xsl:value-of select="$input-xml-name"/>
                                            </file>
                                            
                                            <!-- Any defined focus string for the XSpec test in the manifest -->
                                            <focus>
                                                <xsl:value-of select="$focus"/>
                                            </focus>
                                            
                                            <!-- Step output file -->
                                            <out>
                                                <xsl:value-of select="$uri"/>
                                            </out>
                                            
                                            <!-- Step input file -->
                                            <in>
                                                <xsl:choose>
                                                    <!-- If we're looking at the very first step -->
                                                    <xsl:when test="$previous-number=0">
                                                        <!-- The path to the current dir -->
                                                        <xsl:variable name="path">
                                                            <xsl:value-of select="substring-before($uri,concat('/',$current-number,'-'))"/>
                                                        </xsl:variable>
                                                        
                                                        <!-- The step input is a copy of the input XML, named '0-filename' -->
                                                        <xsl:value-of select="concat($path,'/',$previous-number,'-',$input-xml-name)"/>
                                                    </xsl:when>
                                                    
                                                    <!-- Any subsequent step -->
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="$uris//uri[following-sibling::uri[1]=$uri]"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                
                                            </in>
                                        </pair>
                                        
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                            </xsl:variable>
                            
                            <xsl:copy-of select="$out-in"/>
                            
                        </xsl:for-each>
                    </xspec>
                    
                </xsl:for-each>
                
            </xspecs>
        </xsl:variable>
        
        <!-- Loop through each generated 'pair' (step input/output XML) -->
        <xsl:for-each select="$xspecs//xspec/pair">
            <!-- The original XSpec -->
            <xsl:variable name="current-xspec" select="parent::xspec/@href"/>
            
            <!-- The XSLT -->
            <xsl:variable name="stylesheet" select="parent::xspec/@xslt"/>
            
            <!-- The current 'pair' -->
            <xsl:variable name="pair" select="."/>
            
            <!-- The instance XSpec filename -->
            <xsl:variable name="instance-xspec">
                <xsl:value-of select="concat($tmp-folder,'/xspec-tests/',$pair//file,'-',tokenize($current-xspec,'/')[last()])"/>
            </xsl:variable>
            
            <!-- Serialise the instance XSpec; in an XProc, this ends up in the secondary output port -->
            <xsl:result-document href="{$instance-xspec}">
                <xsl:apply-templates select="doc($current-xspec)" mode="XSPEC">
                    <xsl:with-param name="pair" select="$pair"/>
                    <xsl:with-param name="stylesheet" select="concat($manifest-path,'/',$stylesheet)"/>
                </xsl:apply-templates>
            </xsl:result-document>
        </xsl:for-each>
        
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Copy the XSpec root element. Add the stylesheet used.</xd:p>
        </xd:desc>
        
        <xd:param name="pair">
            <xd:p>The step input/output file, including test info</xd:p>
        </xd:param>
    </xd:doc>
    
    <xsl:template match="x:description" mode="XSPEC">
        <xsl:param name="pair"/>
        <xsl:param name="stylesheet"/>
        
        <xsl:copy>
            <xsl:copy-of select="@* except @stylesheet"/>
            
            <xsl:attribute name="stylesheet" select="$stylesheet"/>
            <xsl:apply-templates select="node()" mode="XSPEC">
                <xsl:with-param name="pair" select="$pair"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Copy the scenario if the default either has no focus or has a focus matching the one defined in the manifest.</xd:p>
        </xd:desc>
        
        <xd:param name="pair">
            <xd:p>The step input/output file, including test info</xd:p>
        </xd:param>
    </xd:doc>
    
    <xsl:template match="x:scenario" mode="XSPEC">
        <xsl:param name="pair"/>
        <xsl:variable name="focus" select="$pair//focus"/>
        
        <xsl:if test="not(@focus) or @focus='' or @focus=$focus">
            <xsl:copy copy-namespaces="no">
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates select="node()" mode="XSPEC">
                    <xsl:with-param name="pair" select="$pair"/>
                </xsl:apply-templates>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Copy nodes. Modify any <xd:pre>@href</xd:pre> to be the current instance input or output.</xd:p>
            <xd:p><xd:b>Note that @href in x:param is <xd:i>assumed</xd:i> to be the step input XML.</xd:b></xd:p>
        </xd:desc>
        
        <xd:param name="pair">
            <xd:p>The step input/output file, including test info</xd:p>
        </xd:param>
    </xd:doc>
    
    <xsl:template match="node()" mode="XSPEC">
        <xsl:param name="pair"/>
        
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@* except @href"/>
            
            <!-- Not everything has an @href -->
            <xsl:if test="@href">
                
                <xsl:attribute name="href">
                    <xsl:choose>
                        <!-- Context means input -->
                        <xsl:when test="self::x:context">
                            <xsl:value-of select="$pair//in"/>
                        </xsl:when>
                        
                        <!-- Expect means output -->
                        <xsl:when test="self::x:expect">
                            <xsl:value-of select="$pair//out"/>
                        </xsl:when>
                        
                        <!-- Assume other cases to mean input -->
                        <xsl:otherwise>
                            <xsl:value-of select="$pair//in"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                
                
            </xsl:if>
            
            <xsl:apply-templates select="node()" mode="XSPEC">
                <xsl:with-param name="pair" select="$pair"/>
            </xsl:apply-templates>
            
        </xsl:copy>
    </xsl:template>
    
    
    
    
</xsl:stylesheet>