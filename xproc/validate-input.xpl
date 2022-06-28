<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sgproc:validate-input"
    name="validate-input"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sgproc="http://www.sgmlguru.org/ns/xproc/steps"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    
    <p:documentation>This validates XML files in an input directory against a DTD.</p:documentation>
    
    <!-- XProc Tools -->
    <p:import href="../xproc-tools/xproc/recursive-directory-list.xpl"/>
    <!-- http://xml.corbas.co.uk/xml/xproc-tools/recursive-directory-list.xpl -->

    <p:output port="result" sequence="true"/>


    <!-- Input path -->
    <p:option name="input-base-uri" required="true">
        <p:documentation>
            <p>Source document(s) URI. Every document ending with suffix <em>$include-filter</em> in this folder and its subfolders is transformed.</p>
        </p:documentation>
    </p:option>

    <p:option name="include-filter" select="'\.xml'" required="false">
        <p:documentation>
            <p>The file suffix of the input files to be converted. Leaving this empty will attempt to convert everything, so don't do it unless you know what you're doing.</p>
        </p:documentation>
    </p:option>

    <!-- Exclude filter -->
    <p:option name="exclude-filter" select="'-validation-'" required="false">
        <p:documentation>
            <p>Exclude filenames with this pattern.</p>
        </p:documentation>
    </p:option>

    <!-- Report save location -->
    <p:option name="reports-dir" select="concat($input-base-uri,'/dtd-validation')">
        <p:documentation>
            <p>Path to which the validation reports should be saved.</p>
        </p:documentation>
    </p:option>

    <!-- Enable validation -->
    <p:option name="validate" select="'false'"/>




    <!-- List input files -->
    <sgproc:recursive-directory-list name="source-files">
        <p:with-option name="path" select="$input-base-uri"/>
        <p:with-option name="resolve" select="'true'"/>
        <p:with-option name="include-filter" select="$include-filter"/>
        <p:with-option name="exclude-filter" select="$exclude-filter"/>
    </sgproc:recursive-directory-list>


    <!-- Validate input -->
    <p:for-each name="validate">
        
        <p:with-input select="//c:file"/>
        
        <p:output port="result" sequence="true"/>
        
        <p:variable name="current-doc" select="/c:file/@name"/>
        <p:variable name="current-uri" select="xs:string(/c:file/@uri)"/>


        <p:try name="test-validate">
            <p:group>
                <p:choose>
                    <p:when test="$validate='true'">
                        <p:load
                            message="{'Validating ' || $current-uri}"
                            parameters="map{'dtd-validate': true()}">
                            <p:with-option
                                name="href"
                                select="$current-uri"/>
                        </p:load>
                    </p:when>
                    <p:otherwise>
                        <p:identity>
                            <p:with-input port="source">
                                <p:empty/>
                            </p:with-input>
                        </p:identity>
                    </p:otherwise>
                </p:choose>

            </p:group>

            <p:catch name="catch">
                <p:identity
                    name="errors"
                    message="{//c:errors}">
                    <p:with-input port="source">
                        <p:pipe
                            port="error"
                            step="catch"/>
                    </p:with-input>
                </p:identity>
                <p:store
                    message="{concat('Saving DTD validation results to ', $reports-dir,'/', 'dtd',$exclude-filter, $current-doc)}">
                    <p:with-option
                        name="href"
                        select="concat($reports-dir,'/', 'dtd',$exclude-filter, $current-doc)"/>
                    <p:with-input port="source">
                        <p:pipe
                            port="result"
                            step="errors"/>
                    </p:with-input>
                </p:store>
            </p:catch>
        </p:try>
    </p:for-each>
    
</p:declare-step>
