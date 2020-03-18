# XSpec-in-Pipeline Functionality

This describes the XSpec functionality that is meant to run after an XSLT pipeline.


## Basics

Let's say we have an XSLT manifest that runs a couple of XSLTs in sequence:

```XML
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="../xproc-tools/schemas/manifest.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<manifest
    xmlns="http://www.corbas.co.uk/ns/transforms/data"
    xml:base=".">
    
    <group description="Test group">
        
        <item href="step1.xsl" description="section to level"/>
        <item href="step2.xsl" description="emph to italic"/>
        <item href="step3.xsl" description="title to heading"/>
        <item href="step4.xsl" description="removes @weird"/>
        
    </group>
</manifest>
```

With the right property set, the pipeline will produce debug output in temp folders, one per input file, so for four input XML files `test.xml`, `test1.xml`, `test2.xml`, and `test3.xml`, the debug folders (note that there is one temp subfolder per input file) will contain the following:

```
tmp/:
total 20K
drwxrwxr-x 2 ari ari 4.0K May  3 13:38 test1.xml
drwxrwxr-x 2 ari ari 4.0K May  3 13:38 test2.xml
drwxrwxr-x 2 ari ari 4.0K May  3 13:38 test3.xml
drwxrwxr-x 2 ari ari 4.0K May  3 13:38 test.xml

tmp/test1.xml:
total 16K
-rw-rw-r-- 1 ari ari 187 May  3 13:38 0-step1.xsl.xml
-rw-rw-r-- 1 ari ari 187 May  3 13:38 1-step1.xsl.xml
-rw-rw-r-- 1 ari ari 187 May  3 13:38 2-step2.xsl.xml
-rw-rw-r-- 1 ari ari 183 May  3 13:38 3-step3.xsl.xml
-rw-rw-r-- 1 ari ari 183 May  3 13:38 4-step4.xsl.xml

tmp/test2.xml:
total 16K
-rw-rw-r-- 1 ari ari 249 May  3 13:38 0-step1.xsl.xml
-rw-rw-r-- 1 ari ari 249 May  3 13:38 1-step1.xsl.xml
-rw-rw-r-- 1 ari ari 245 May  3 13:38 2-step2.xsl.xml
-rw-rw-r-- 1 ari ari 241 May  3 13:38 3-step3.xsl.xml
-rw-rw-r-- 1 ari ari 241 May  3 13:38 4-step4.xsl.xml

tmp/test3.xml:
total 16K
-rw-rw-r-- 1 ari ari 249 May  3 13:38 0-step1.xsl.xml
-rw-rw-r-- 1 ari ari 249 May  3 13:38 1-step1.xsl.xml
-rw-rw-r-- 1 ari ari 245 May  3 13:38 2-step2.xsl.xml
-rw-rw-r-- 1 ari ari 241 May  3 13:38 3-step3.xsl.xml
-rw-rw-r-- 1 ari ari 241 May  3 13:38 4-step4.xsl.xml

tmp/test.xml:
total 16K
-rw-rw-r-- 1 ari ari 308 May  3 13:38 0-step1.xsl.xml
-rw-rw-r-- 1 ari ari 308 May  3 13:38 1-step1.xsl.xml
-rw-rw-r-- 1 ari ari 304 May  3 13:38 2-step2.xsl.xml
-rw-rw-r-- 1 ari ari 300 May  3 13:38 3-step3.xsl.xml
-rw-rw-r-- 1 ari ari 287 May  3 13:38 4-step4.xsl.xml

```

Here, the temp file `1-step1.xsl.xml` is the output from the first XSLT, `step1.xsl`, the temp file `2-step2.xsl.xml` is the output from the second XSLT, `step2.xsl`, and so on.

**NOTE! `0-step1.xsl.xml` is a copy of the unchanged input file, copied to the temp folder by the conversion pipeline when generating and running the XSpec tests.**

We can't apply XSpec tests directly on the inputs and outputs of a pipeline, of course, since XSpecs act on a single XSLT, not a sequence of them. Neither can we apply an XSpec test on a batch of input and output files since XSpecs act on a single file at a time. 

This means that we need to create one XSpec test per transformation. An XSpec `step1.xspec`, for example, might test the first transformation step. It will only act on a single input and output at a time. For example:

```XML
<x:scenario
    label="When processing sgt:section elements">
    <x:context
        href="../test-content/test.xml"/>
    <x:expect
        label="the same number of level elements should result"
        test="count(//level) = $n-o-sections"/>
</x:scenario>
```

Note the presence of `x:context/@href`. Similarly, there might be an `x:expect/@href`.

Thus, when transformming a batch of files, there needs to be a test for each file and XSLT step.

Not every step will require XSpec tests, so a manifest file, similar to the XSLT manifest, above, could be used to list those steps that do need one. For example:


```XML
?xml version="1.0" encoding="UTF-8"?>
<tests 
    xmlns="http://www.sgmlguru.org/ns/xproc/steps" 
    manifest="../test-xslt/test-manifest.xml"
    xml:base=".">
    
    <!-- Use paths relative to /tests/@xml:base for pipeline manifest, XSLT and XSpec -->
    
    <test 
        xslt="../test-xslt/step1.xsl" 
        xspec="step1.xspec" 
        focus="batch"/>
    
</tests>
```

This tests a single XSLT step, given in `test/@xslt="../test-xslt/step1.xsl"`. We'd therefore need to generate XSpec tests for each and every input file, so we get something XSpec tests generated for each file:

```
tmp/:
total 20K
drwxrwxr-x 2 ari ari 4.0K May 28 15:24 generated-xspecs
drwxrwxr-x 2 ari ari 4.0K May  3 13:38 test1.xml
drwxrwxr-x 2 ari ari 4.0K May  3 13:38 test2.xml
drwxrwxr-x 2 ari ari 4.0K May  3 13:38 test3.xml
drwxrwxr-x 2 ari ari 4.0K May  3 13:38 test.xml

tmp/generated-xspecs:
total 16K
-rw-rw-r-- 1 ari ari 1.4K May 28 16:38 test1.xml-step1.xspec
-rw-rw-r-- 1 ari ari 1.4K May 28 16:38 test2.xml-step1.xspec
-rw-rw-r-- 1 ari ari 1.4K May 28 16:38 test3.xml-step1.xspec
-rw-rw-r-- 1 ari ari 1.4K May 28 16:38 test.xml-step1.xspec

```

This can be done with a relatively simple XSLT. This XSLT takes as its input the URI to the temp folder containing the debug output and the path to the XSpec manifest.


## Running the Tests

A batch conversion, validation, and XSpec tests should run as follows:

1. Validate input files (optional)
2. Convert the input files using an XSLT pipeline; debug required
3. Validate the results (optional)
4. Generate XSpec tests for each XSLT (listed in an XSpec manifest) and file.
5. Run the generated XSpec tests
6. Save the reports

Note that running the XSpecs actually involves three steps:

1. Generate XSLTs from XSpecs using `generate-xspec-tests.xsl`
2. Run the generated XSLTs
3. Convert the resulting reports to HTML using `format-xspec-report.xsl`

See [Running Scenarios](https://github.com/xspec/xspec/wiki/Running-Scenarios) on the XSpec Wiki.


## XSpecs Pipeline

The XProc pipeline in `xproc/run-xspecs.xpl` generates the instance XSpecs based on the URI to the temp folder and the URI to the XSpec manifest:

```
<p:declare-step type="sg:validate-convert">
  <p:option name="xspec-manifest-uri"/>
  <p:option name="tmp-folder-uri"/>
  <p:option name="run-xspecs"/>
</p:declare-step>
```

The `xspec-manifest-uri` and `tmp-folder-uri` options are fairly self-explanatory. The `run-xspecs` option enables or disables generating and running the XSpec tests, with the possible values 'true' and 'false' (default).

The input ports are static, defined by the pipeline itself, and not shown here. They point out the XSLTs required to generate instance XSpecs, convert the XSpecs to XSLTs, and convert the resulting XML test reports to HTML, respectively.


### What the Pipeline Does

The XProc pipeline runs the following:

* `xslt/generate-instance-xspecs.xsl` (generates instance XSpecs)
* `../xspec/src/compiler/generate-xspec-tests.xsl` (generates XSLT from XSpec; part of the XSpec distribution)
* `../xspec/src/reporter/format-xspec-report.xsl` (converts the XSpec report XML to HTML; part of the XSpec distribution)
* Saves the XHTML reports in a subfolder `xspec-tests` to the temp folder where the intermediate XML is stored (so next to the folders per input file)


### Testing the Pipeline

There is a shell script `xproc/run-xspecs.sh` that runs the `run-xspecs.xpl` pipeline, without any preceding conversion of any kind. Currently you'll have to provide an example pipeline and update any paths inside the shell script.

If you wish to run the `run-xspecs.xpl` pipeline on some other debug material, you **need to change `tmp-folder-uri` accordingly in the shell script**.


### Using `validate-convert.sh` or Other Wrapper Scripts

You can also run the conversion wrapper pipeline, `validate-convert.xpl`, by using the shell script `validate-convert.sh`.

The `xlsx2xml.xpl` pipeline is a wrapper to the wrapper - it runs `validate-convert.xpl` as its second main part, the first being extracting XML from an Excel archive.


## Writing XSpecs

To use the XSpec functionality, there are a few gotchas when writing XSpec tests:

* Currently, you should only use a global parameter (`x:param`) with an `@href` pointing at the *input XML*. This has to do with limitations in how the `generate-instance xspecs.xsl` stylesheet recognises what `@href` is used for (input or output).1
* You should write your XSpec tests against relevant XSLT pipeline debug step outputs. Any `@href` attributes will be converted to the currently tested XML instance.
* The paths in an *XSpec manifest* should be given *relative to it*. The individual XSpecs, then, will usually be in the same folder as the manifest, while the XSLT stylesheets should be somewhere else (say, `../xslt/mystylesheet.xsl`).
* You should name your XSpec the same as the XSLT step it tests, but using an `.xspec` suffix. This is not a must but will considerably ease debugging.

