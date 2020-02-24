<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sg:validate-with-schematron"
    name="validate-with-schematron"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sg="http://www.sgmlguru/ns/xproc/steps"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
    version="1.0">

    <!-- Schematron -->
    <p:input port="sch">
        <p:documentation>
            <p>The Schematron to be used for validation.</p>
        </p:documentation>
    </p:input>


    <p:output port="result" sequence="true"/>


    <p:option name="input-base-uri">
        <p:documentation>
            <p>Source document(s) URI. Every document ending with suffix <em>$include-filter</em> in this folder and its subfolders is transformed.</p>
        </p:documentation>
    </p:option>

    <!-- Include filter -->
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
    <p:option name="reports-dir" select="concat($input-base-uri,'/sch-validation')">
        <p:documentation>
            <p>Path to which the validation reports should be saved.</p>
        </p:documentation>
    </p:option>

    <!-- Enable validation -->
    <p:option name="validate" select="'true'"/>


    <!-- XProc Tools -->
    <p:import href="../xproc-tools/xproc/recursive-directory-list.xpl"/>

    <!-- Calabash extensions -->
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>


    <!-- Should we validate? -->
    <p:choose>
        <p:when test="$validate='true'">
            <!-- List input files -->
            <ccproc:recursive-directory-list name="source-files">
                <p:with-option name="path" select="$input-base-uri"/>
                <p:with-option name="resolve" select="'true'"/>
                <p:with-option name="include-filter" select="$include-filter"/>
                <p:with-option name="exclude-filter" select="$exclude-filter"/>
            </ccproc:recursive-directory-list>

            <!-- Validate input -->
            <p:for-each name="schematron-loop">

                <p:output port="result" primary="true" sequence="true"/>

                <p:iteration-source select="//c:file">
                    <p:pipe port="result" step="source-files"/>
                </p:iteration-source>

                <p:variable name="file" select="/c:file/@uri"/>

                <p:variable name="current-doc" select="/c:file/@name"/>

                <cx:message>
                    <p:with-option
                        name="message"
                        select="if ($validate='true')
                        then (concat('Validating ',/c:file/@uri,' with Schematron'))
                        else ()"/>
                </cx:message>

                <!-- Load current input -->
                <p:load name="current-input-doc">
                    <p:with-option name="href" select="$file"/>
                </p:load>

                <p:validate-with-schematron name="schematron" assert-valid="false">
                    <p:input port="schema">
                        <p:pipe port="sch" step="validate-with-schematron"/>
                    </p:input>
                    <p:input port="parameters">
                        <p:empty/>
                    </p:input>
                </p:validate-with-schematron>

                <p:sink/>

                <p:identity name="errors">
                    <p:input port="source">
                        <p:pipe port="report" step="schematron"/>
                    </p:input>
                </p:identity>

                <cx:message>
                    <p:with-option name="message" select="/">
                        <p:pipe port="report" step="schematron"/>
                    </p:with-option>
                </cx:message>

                <!-- Uncomment to store SVRL XML -->
                <!--<p:store>
                    <p:with-option
                        name="href"
                        select="concat($reports-dir,'/', 'sch',$exclude-filter, $current-doc)"/>
                    <p:input port="source">
                        <p:pipe port="result" step="errors"/>
                    </p:input>
                </p:store>-->

                <p:choose>

                    <p:variable name="count" select="count(.//svrl:failed-assert)">
                        <p:pipe port="report" step="schematron"/>
                    </p:variable>

                    <p:when test="$count &gt; 0">

                        <cx:message>
                            <p:with-option
                               name="message"
                               select="concat('Saving Schematron validation results to ', $reports-dir,'/', 'sch',$exclude-filter, replace($current-doc,'\.xml','.htm'))"/>
                        </cx:message>

                        <p:xslt name="svrl-html">
                            <p:input port="source">
                                <p:pipe port="result" step="errors"/>
                            </p:input>
                            <p:input port="stylesheet">
                                <p:document href="xslt/svrl2html.xsl"/>
                            </p:input>
                            <p:input port="parameters">
                                <p:empty/>
                            </p:input>
                        </p:xslt>

                        <p:store>
                            <p:with-option
                                name="href"
                                select="replace(concat($reports-dir,'/', 'sch',$exclude-filter, $current-doc),'\.xml','.htm')"/>
                            <p:input port="source">
                                <p:pipe port="result" step="svrl-html"/>
                            </p:input>
                        </p:store>
                    </p:when>

                    <p:otherwise>
                        <p:sink/>
                    </p:otherwise>
                </p:choose>



                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>

            </p:for-each>
        </p:when>

        <p:otherwise>
            <p:identity>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>

    <p:identity/>

</p:declare-step>
