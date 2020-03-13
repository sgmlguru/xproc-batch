<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    type="sg:validate-convert"
    name="validate-convert"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:sg="http://www.sgmlguru/ns/xproc/steps"
    xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
    version="1.0">

    <!-- XSLTs -->
    <p:input port="manifest">
        <p:documentation>
            <p>The manifest file listing the XSLT steps used by the transformation.</p>
        </p:documentation>
    </p:input>

    <!-- Optional XSLT params -->
    <p:input port="parameters" kind="parameter">
        <p:documentation>
            <p>Optional parameters fed to the pipelined XSLT.</p>
        </p:documentation>
    </p:input>

    <!-- Schematron -->
    <p:input port="sch">
        <p:documentation>
            <p>The Schematron used in the input and output validation.</p>
        </p:documentation>
    </p:input>


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

    <p:option name="exclude-filter" select="''"/>

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
    <p:option name="doctype-system" select="''"/>

    <!-- Output DOCTYPE PUBLIC identifier -->
    <p:option name="doctype-public" select="''"/>

    <!-- Enable verbose output -->
    <p:option name="verbose" select="'true'"/>

    <!-- Enable debug output (intermediate results on pipeline) -->
    <p:option name="debug" select="'true'"/>

    <!-- Enable input DTD validation -->
    <p:option name="dtd-validate-input" select="'false'"/>

    <!-- Enable output DTD validation -->
    <p:option name="dtd-validate-output" select="'false'"/>

    <!-- Enable input SCH validation -->
    <p:option name="sch-validate-input" select="'false'"/>

    <!-- Enable output SCH validation -->
    <p:option name="sch-validate-output" select="'false'"/>

    <!-- Enable XSpec tests -->
    <p:option name="run-xspecs" select="'false'"/>

    <!-- XSpec Manifest URI -->
    <p:option name="xspec-manifest-uri" select="''"/>

    
    <!-- Import batch convert step -->
    <p:import href="batch-convert.xpl"/>

    <!-- Import DTD validation step -->
    <p:import href="validate-input.xpl"/>

    <!-- Import Schematron validation step -->
    <p:import href="validate-with-schematron.xpl"/>

    <!-- Import XSpec tests step -->
    <p:import href="../xspec-tools/xproc/run-xspecs.xpl"/>

    <!-- Calabash extensions -->
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>


    <!-- Validate the input XML (done AFTER the conversion) -->
    <sg:validate-input cx:depends-on="batch" name="before">
        <p:with-option name="input-base-uri" select="$input-base-uri"/>
        <p:with-option name="reports-dir" select="concat($reports-dir,'/sources/dtd-validation')"/>
        <p:with-option name="validate" select="$dtd-validate-input"/>
    </sg:validate-input>

    <p:sink/>

    <!-- Validate input against Schematron -->
    <sg:validate-with-schematron cx:depends-on="batch">
        <p:input port="sch">
            <p:pipe port="sch" step="validate-convert"/>
        </p:input>
        <p:with-option name="input-base-uri" select="$input-base-uri"/>
        <p:with-option name="reports-dir" select="concat($reports-dir,'/sources/sch-validation')"/>
        <p:with-option name="validate" select="$sch-validate-input"/>
    </sg:validate-with-schematron>

    <p:sink/>


    <!-- Convert the input -->
    <sg:batch-convert name="batch">
        <p:input port="manifest">
            <p:pipe port="manifest" step="validate-convert"/>
        </p:input>
        <p:input port="parameters">
            <p:pipe port="parameters" step="validate-convert"/>
        </p:input>
        <p:with-option name="input-base-uri" select="$input-base-uri"/>
        <p:with-option name="output-base-uri" select="$output-base-uri"/>
        <p:with-option name="tmp-dir" select="$tmp-dir"/>
        <p:with-option name="doctype-system" select="$doctype-system"/>
        <p:with-option name="doctype-public" select="$doctype-public"/>
        <p:with-option name="verbose" select="$verbose"/>
        <p:with-option name="debug" select="$debug"/>
    </sg:batch-convert>


    <!-- Validate the output -->
    <sg:validate-input cx:depends-on="run-xspecs">
        <p:with-option name="input-base-uri" select="$output-base-uri"/>
        <p:with-option name="reports-dir" select="concat($reports-dir,'/target/dtd-validation')"/>
        <p:with-option name="validate" select="$dtd-validate-output"/>
    </sg:validate-input>

    <p:sink/>


    <!-- Run XSpec tests -->
    <sg:run-xspecs name="run-xspecs" cx:depends-on="batch">
        <p:with-option name="tmp-folder-uri" select="$tmp-dir"/>
        <p:with-option name="xspec-manifest-uri" select="$xspec-manifest-uri"/>
        <p:with-option name="run-xspecs" select="$run-xspecs"/>
    </sg:run-xspecs>


    <!-- Validate output against Schematron -->
    <sg:validate-with-schematron cx:depends-on="batch">
        <p:input port="sch">
            <p:pipe port="sch" step="validate-convert"/>
        </p:input>
        <p:with-option name="input-base-uri" select="$output-base-uri"/>
        <p:with-option name="reports-dir" select="concat($reports-dir,'/target/sch-validation')"/>
        <p:with-option name="validate" select="$sch-validate-output"/>
    </sg:validate-with-schematron>


    <p:identity name="last"/>
</p:declare-step>
