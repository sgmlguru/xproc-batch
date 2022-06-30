<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sgproc:validate-convert"
    name="validate-convert"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sgproc="http://www.sgmlguru.org/ns/xproc/steps"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    version="3.0">
    
    <p:documentation></p:documentation>
    
    
    <!-- Import batch convert step -->
    <p:import href="./batch-convert.xpl"/>
    <!-- http://www.sgmlguru/ns/xproc/steps/batch-convert.xpl -->
    
    <!-- Import DTD validation step -->
    <p:import href="./validate-input.xpl"/>
    <!-- http://www.sgmlguru/ns/xproc/steps/validate-input.xpl -->
    
    <!-- Import Schematron validation step -->
    <p:import href="./validate-with-schematron.xpl"/>
    <!-- http://www.sgmlguru/ns/xproc/steps/validate-with-schematron.xpl -->
    
    <!-- Import XSpec tests step -->
    <p:import href="./run-xspecs.xpl"/>
    <!-- http://www.sgmlguru/ns/xproc/steps/run-xspecs.xpl -->
    
    

    <!-- XSLTs -->
    <p:input port="manifest">
        <p:documentation>
            <p>The manifest file listing the XSLT steps used by the transformation.</p>
        </p:documentation>
    </p:input>

    <!-- Schematron -->
    <p:input port="sch">
        <p:documentation>
            <p>The Schematron used in the input and output validation.</p>
        </p:documentation>
    </p:input>


    <p:output port="result" sequence="true"/>
    
    
    <!-- Optional XSLT params -->
    <p:option name="parameters" required="false" as="xs:string*">
        <p:documentation>
            <p>Optional parameters fed to the pipelined XSLT.</p>
        </p:documentation>
    </p:option>

    <!-- Input path -->
    <p:option name="input-base-uri" required="true">
        <p:documentation>
            <p>Source document(s) URI. Every document ending with suffix <em>$include-filter</em> in this folder and its subfolders is transformed.</p>
        </p:documentation>
    </p:option>

    <p:option name="include-filter" required="false" as="xs:string?">
        <p:documentation>
            <p>The file suffix of the input files to be converted. Leaving this empty will attempt to convert everything, so don't do it unless you know what you're doing.</p>
        </p:documentation>
    </p:option>

    <p:option name="exclude-filter" required="false" as="xs:string?"/>

    <!-- Output -->
    <p:option name="output-base-uri" required="true">
        <p:documentation>
            <p>Output URI for the transformed files.</p>
        </p:documentation>
    </p:option>

    <!-- Reports -->
    <p:option name="reports-dir" required="true">
        <p:documentation>
            <p>URI for validation reports.</p>
        </p:documentation>
    </p:option>

    <!-- Tmp -->
    <p:option name="tmp-dir" required="true">
        <p:documentation>
            <p>URI for debug (intermediate result) files.</p>
        </p:documentation>
    </p:option>

    <!-- Output DOCTYPE SYSTEM identifier -->
    <p:option name="doctype-system" select="''" required="false" as="xs:string?"/>

    <!-- Output DOCTYPE PUBLIC identifier -->
    <p:option name="doctype-public" select="''" required="false" as="xs:string?"/>

    <!-- Enable verbose output -->
    <p:option name="verbose" select="'true'" required="false"/>

    <!-- Enable debug output (intermediate results on pipeline) -->
    <p:option name="debug" select="'true'" required="false"/>

    <!-- Enable input DTD validation -->
    <p:option name="dtd-validate-input" select="'false'" required="false"/>

    <!-- Enable output DTD validation -->
    <p:option name="dtd-validate-output" select="'false'" required="false"/>

    <!-- Enable output SCH validation -->
    <p:option name="sch-validate-output" select="'false'" required="false"/>

    <!-- Enable XSpec tests -->
    <p:option name="run-xspecs" select="'false'" required="false"/>

    <!-- XSpec Manifest URI -->
    <p:option name="xspec-manifest-uri" select="''" required="false"/>

    
    
    <!-- Validate the input XML (done AFTER the conversion) -->
    <sgproc:validate-input name="before">
        <p:with-option name="input-base-uri" select="$input-base-uri"/>
        <p:with-option name="reports-dir" select="concat($reports-dir,'/sources/dtd-validation')"/>
        <p:with-option name="validate" select="$dtd-validate-input"/>
    </sgproc:validate-input>

    <p:sink/>


    <!-- Convert the input -->
    <sgproc:batch-convert name="batch">
        <p:with-input port="manifest">
            <p:pipe port="manifest" step="validate-convert"/>
        </p:with-input>
        <p:with-option name="parameters" select="$parameters"/>
        <p:with-option name="include-filter" select="$include-filter"/>
        <p:with-option name="exclude-filter" select="$exclude-filter"/>
        <p:with-option name="input-base-uri" select="$input-base-uri"/>
        <p:with-option name="output-base-uri" select="$output-base-uri"/>
        <p:with-option name="tmp-dir" select="$tmp-dir"/>
        <p:with-option name="doctype-system" select="$doctype-system"/>
        <p:with-option name="doctype-public" select="$doctype-public"/>
        <p:with-option name="verbose" select="$verbose"/>
        <p:with-option name="debug" select="$debug"/>
    </sgproc:batch-convert>


    <!-- Validate the output -->
    <sgproc:validate-input>
        <p:with-option name="input-base-uri" select="$output-base-uri"/>
        <p:with-option name="reports-dir" select="concat($reports-dir,'/target/dtd-validation')"/>
        <p:with-option name="validate" select="$dtd-validate-output"/>
    </sgproc:validate-input>

    <p:sink/>


    <!-- Run XSpec tests -->
    <p:choose depends="batch" name="xspecs">
        <p:when test="$debug!='true' and $run-xspecs='true'">
            <p:output sequence="true">
                <p:empty/>
            </p:output>
            <p:identity message="$debug={$debug}: it must be set to true to run XSpec tests'">
                <p:with-input>
                    <p:empty/>
                </p:with-input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:output sequence="true">
                <p:empty/>
            </p:output>
            <sgproc:run-xspecs name="run-xspecs">
                <p:with-option name="tmp-folder-uri" select="$tmp-dir"/>
                <p:with-option name="xspec-manifest-uri" select="$xspec-manifest-uri"/>
                <p:with-option name="run-xspecs" select="$run-xspecs"/>
            </sgproc:run-xspecs>
        </p:otherwise>
    </p:choose>
    
    
    <!-- Validate output against Schematron -->
    <sgproc:validate-with-schematron cx:depends-on="batch">
        <p:with-input port="sch">
            <p:pipe port="sch" step="validate-convert"/>
        </p:with-input>
        <p:with-option name="input-base-uri" select="$output-base-uri"/>
        <p:with-option name="reports-dir" select="concat($reports-dir,'/target/sch-validation')"/>
        <p:with-option name="validate" select="$sch-validate-output"/>
    </sgproc:validate-with-schematron>


    <p:identity name="last"/>
</p:declare-step>
