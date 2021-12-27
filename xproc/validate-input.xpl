<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sg:validate-input"
    name="validate-input"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sg="http://www.sgmlguru/ns/xproc/steps"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    version="1.0">

    <p:output port="result" sequence="true"/>


    <!-- Input path -->
    <p:option name="input-base-uri" required="true">
        <p:documentation>
            <p>Source document(s) URI. Every document ending with suffix <em>$include-filter</em> in this folder and its subfolders is transformed.</p>
        </p:documentation>
    </p:option>

    <p:option name="include-filter" select="'.xml'">
        <p:documentation>
            <p>The file suffix of the input files to be converted. Leaving this empty will attempt to convert everything, so don't do it unless you know what you're doing.</p>
        </p:documentation>
    </p:option>

    <!-- Exclude filter -->
    <p:option name="exclude-filter" select="'-validation-'">
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


    <!-- XProc Tools -->
    <p:import href="http://xml.corbas.co.uk/xml/xproc-tools/recursive-directory-list.xpl"/>

    <!-- Calabash extensions -->
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>


    <!-- List input files -->
    <ccproc:recursive-directory-list name="source-files">
        <p:with-option name="path" select="$input-base-uri"/>
        <p:with-option name="resolve" select="'true'"/>
        <p:with-option name="include-filter" select="$include-filter"/>
        <p:with-option name="exclude-filter" select="$exclude-filter"/>
    </ccproc:recursive-directory-list>


    <!-- Validate input -->
    <p:for-each name="validate">

        <p:output port="result" primary="true" sequence="true"/>

        <p:iteration-source select="//c:file">
            <p:pipe port="result" step="source-files"/>
        </p:iteration-source>

        <p:variable name="current-doc" select="/c:file/@name"/>
        <p:variable name="current-uri" select="if (starts-with(/c:file/@uri,'file:')) then (/c:file/@uri) else (concat('file:',/c:file/@uri))"/>


        <p:try name="test-validate">
            <p:group>
                <p:output port="result" primary="true"/>

                <p:choose>
                    <p:when test="$validate='true'">
                        <cx:message>
                            <p:with-option
                                name="message"
                                select="if ($validate='true')
                                then (concat('Validating ',$current-uri))
                                else ()"/>
                        </cx:message>
                        <p:load>
                            <p:with-option name="href" select="$current-uri"/>
                            <p:with-option name="dtd-validate" select="$validate"/>
                        </p:load>
                    </p:when>
                    <p:otherwise>
                        <p:identity>
                            <p:input port="source">
                                <p:empty/>
                            </p:input>
                        </p:identity>
                    </p:otherwise>
                </p:choose>

            </p:group>

            <p:catch name="catch">
                <p:output port="result" primary="true">
                    <p:pipe port="result" step="errors"/>
                </p:output>

                <p:identity name="errors">
                    <p:input port="source">
                        <p:pipe port="error" step="catch"/>
                    </p:input>
                </p:identity>

                <cx:message>
                    <p:with-option name="message" select="//c:errors"/>
                </cx:message>

                <cx:message>
                    <p:with-option
                        name="message"
                        select="concat('Saving DTD validation results to ', $reports-dir,'/', 'dtd',$exclude-filter, $current-doc)"/>
                </cx:message>

                <p:store>
                    <p:with-option
                        name="href"
                        select="concat($reports-dir,'/', 'dtd',$exclude-filter, $current-doc)"/>
                    <p:input port="source">
                        <p:pipe port="result" step="errors"/>
                    </p:input>
                </p:store>
            </p:catch>
        </p:try>
    </p:for-each>

    <p:sink/>

    <p:identity name="last">
        <p:input port="source">
            <p:pipe port="result" step="validate"/>
        </p:input>
    </p:identity>
</p:declare-step>
