# README

This repository contains XProc and XSLT scripts to run an XSLT-based pipeline converting XML to XML in batch. It is based on Nic Gibson's XProc Tools (inluded here for convenience) and previous work by yours truly.

There is also an XQuery module and a test XQuery calling the functions in the module, both intended to run in eXist-DB. These, just like the XProc scripts, are intended to run an XSLT pipeline.

In addition to the tools, you'll need a *manifest file* listing your XSLT steps, as well as the XSLT stylesheets themselves. The manifest is an XML file adhering to `xproc-tools/schemas/manifest.rng`.

An example pipeline, complete with a manifest and XSLT stylesheets, is available at (https://github.com/sgmlguru/xslt-pipelines). It should explain how to create your own XSLT pipeline.


## Requirements

At the moment, you'll need one of the following: 
* A recent version of [XML Calabash 1.x.x](https://xmlcalabash.com/). Morgana XProc 1.x won't work because the XProc scripts rely on Calabash extensions. I am going to address this at some point, probably when moving everything to XProc 3.0.
* An [eXist-DB XML database](http://exist-db.org/exist/apps/homepage/index.html), version 5.2 or later.


## Running Pipelines via XProc

Normally, you'll want to run the XProc script `xproc/validate-convert.xpl`, or an XProc that calls it, using a shell script that sets up your conversion inputs and options. It's possible to run it from *oXygen*, too, of course.

For example, let's assume that this repository lives at `/home/ari/Documents/repos/xproc-batch` and the repository with the XSLT manifest and stylesheets lives at `/home/ari/Documents/repos/xlsx2xml`. Furthermore, let's assume that there is a project folder on the local file system containing the actual sources files to be converted at `/home/ari/Documents/projects/colleges/sources`.

Furthermore, we'll assume that XML Calabash is unpacked to `/home/ari/xmlcalabash-1.1.30-99/`.

This shell script would then convert the source files (in this case, some Excel spreadsheets):

```
#!/bin/sh
echo Converting XLSX sources to XML...
        java -classpath "/home/ari/xmlcalabash-1.1.30-99/xmlcalabash-1.1.30-99.jar:\
        /home/ari/xmlcalabash-1.1.30-99/lib/Saxon-HE-9.9.1-5.jar:\
        /home/ari/xmlcalabash-1.1.30-99/lib/commons-logging-1.2.jar:\
        /home/ari/xmlcalabash-1.1.30-99/lib/httpclient-4.5.8.jar:\
        /home/ari/xmlcalabash-1.1.30-99/lib/commons-codec-1.11.jar:\
        /home/ari/xmlcalabash-1.1.30-99/lib/commons-io-2.2.jar" \
        -Dxml.catalog.files="/home/ari/Documents/repos/xproc-batch/catalogs/catalog.xml"\
         com.xmlcalabash.drivers.Main\
          --entity-resolver org.xmlresolver.Resolver \
          --input manifest=file:/home/ari/Documents/repos/xlsx2xml/pipelines/poc/poc-xlsx2xml-manifest.xml \
          --input sch=/home/ari/Documents/repos/xlsx2xml/sch/placeholder.sch \input-base-uri=file:/home/ari/Documents/projects/colleges/poc/sources \
          output-base-uri=/home/ari/Documents/projects/colleges/poc/tmp/out \
          reports-dir=/home/ari/Documents/projects/colleges/poc/tmp/reports \
          tmp-dir=/home/ari/Documents/projects/colleges/poc/tmp \
          xspec-manifest-uri=file:/path/to/xspec-manifest.xml \
          verbose=true debug=true \
          dtd-validate-input=false dtd-validate-output=false \
          sch-validate-input=false sch-validate-output=false \
          run-xspecs=false extract-xlsx=true \
          /home/ari/Documents/repos/xproc-batch/xproc/xlsx2xml.xpl

```

* `--input manifest=file:/home/ari/Documents/repos/xlsx2xml/pipelines/poc/poc-xlsx2xml-manifest.xml` points out the XSLT manifest file.
* `--input sch=/home/ari/Documents/repos/xlsx2xml/sch/placeholder.sch` is the Schematron used to validate the output.
* `input-base-uri=file:/home/ari/Documents/projects/colleges/poc/sources` is the location of the source files. 
* `output-base-uri=/home/ari/Documents/projects/colleges/poc/tmp/out` is where the converted XML files will be saved.
* `reports-dir=/home/ari/Documents/projects/colleges/poc/tmp/reports` is the location of any generated reports.
* `tmp-dir=/home/ari/Documents/projects/colleges/poc/tmp` is the path to a temp folder where any output, debug info, and reports are saved.
* `xspec-manifest-uri=file:/path/to/xspec-manifest.xml` points out an XSpec tests manifest file. This is run if `run-xspecs=true`. The XSpec manifest file format is described by `xspec-tools/rng/xspec-manifest.rnc` (see `xspec-tools/README.md` for more).
* `debug=true` produces debug output for each XSLT step in the manifest.
* `/home/ari/Documents/repos/xproc-batch/xproc/xlsx2xml.xpl` is the actual XProc pipeline being run.

You might also want the output to validate against a DTD. Adding `doctype-public` or `doctype-system` (or both) to the shell script will add a `DOCTYPE` declaration to the output. These are serialisation options set in the XProc script.

Given the above, the XProc script will, when run, add an output structure like so:

```
projects/colleges
    poc
        sources
        tmp
            out
                (XML output)
            debug
                (step debug XML)
            reports
                (validation reports)
            xml
                (normalised XML for spreadsheets - this pipeline only)
```

The output is stored in `tmp/out`.


## Debugging a Pipeline

When `debug=true`, the script adds debug output to `tmp/debug/`, with a subdirectory for each input file.

For example, let's assume that our source file is `/home/ari/Documents/projects/findcourses/poc/sources/Activate_Learning.xml` and our XSLT pipeline manifest looks like this (real-life example):

```XML
<manifest xmlns="http://www.corbas.co.uk/ns/transforms/data" xml:base=".">
    
    <group description="XLSX normalisation and cleanup steps" xml:base="../../xslt/common/">
        <item href="XLSX-UTIL_remove-empty.xsl" description="Remove empty sheet rows"/>
        <item href="XLSX-UTIL_normalisation.xsl" description="Include shared strings inline"/>
        <item href="XLSX-UTIL_hyperlinks.xsl" description="Normalise hyperlinks"/>
        <item href="XLSX-UTIL_cleanup.xsl" description="Remove unneeded XLSX elements"/>
    </group>
    
    <group description="Convert XLSX to exchange intermediate XML" xml:base="../../xslt/common/">
        <item href="XLSX2XML_structure.xsl" description="Convert to the main wrappers and generate a coordinate lookup"/>
        <item href="XLSX2XML_courses.xsl" description="Convert rows to courses"/>
        <item href="XLSX2XML_dates.xsl" description="Convert ECMA-376 dates to human-readable format"/>
        <item href="XLSX2XML_locations.xsl" description="Extract location info from course data to locations wrapper, leave behind converted location info in courses"/>
        <item href="XLSX2XML_fields.xsl" description="Convert every remaining cell to @target-mamed elements"/>
    </group>
    
    <group description="Convert from exchange intermediate to target XML format" xml:base="../../xslt/exc2xi/">
        <item href="EXC2XI_course.xsl" description="Add course attributes"/>
        <item href="EXC2XI_content-fields.xsl" description="Add custom content fields and make the contents into CDATA sections"/>
        <item href="EXC2XI_course-links.xsl" description="Convert course-links to links"/>
        <item href="EXC2XI_categories.xsl" description="Convert category info"/>
        <item href="EXC2XI_exc-locations.xsl" description="Convert locations info from exc to target"/>
        <item href="EXC2XI_exc-events.xsl" description="Generate events"/>
        <item href="EXC2XI_exc-duration.xsl" description="Generate duration info"/>
        <item href="EXC2XI_exc-email.xsl" description="Add receiver email"/>
    </group>
    
    <group description="Cleanup steps" xml:base="../../xslt/exc2xi/">
        <item href="EXC2XI_xi-dedupe.xsl" description="Dedupe courses with the same ID. Keep events from all course instances."/>
        <item href="EXC2XI_xi-cleanup.xsl" description="Cleanup step"/>
    </group>
    
</manifest>
```

The pipeline will produce debug output in `/home/ari/Documents/projects/findcourses/poc/tmp/debug/Activate_Learning.xml/` as follows:

```
ari@toddao:~/Documents/projects/findcourses/poc/tmp/debug/Activate_Learning.xml$ ls -lh
total 106M
-rw-r--r-- 1 ari ari 3,5M mar  5 16:16 0-Activate_Learning.xml
-rw-r--r-- 1 ari ari 3,5M mar  5 16:16 1-XLSX-UTIL_remove-empty.xsl.xml
-rw-r--r-- 1 ari ari 6,4M mar  5 16:16 2-XLSX-UTIL_normalisation.xsl.xml
-rw-r--r-- 1 ari ari 6,4M mar  5 16:16 3-XLSX-UTIL_hyperlinks.xsl.xml
-rw-r--r-- 1 ari ari 4,8M mar  5 16:16 4-XLSX-UTIL_cleanup.xsl.xml
-rw-r--r-- 1 ari ari 4,9M mar  5 16:16 5-XLSX2XML_structure.xsl.xml
-rw-r--r-- 1 ari ari 6,2M mar  5 16:16 6-XLSX2XML_courses.xsl.xml
-rw-r--r-- 1 ari ari 5,6M mar  5 16:16 7-XLSX2XML_dates.xsl.xml
-rw-r--r-- 1 ari ari 5,6M mar  5 16:16 8-XLSX2XML_locations.xsl.xml
-rw-r--r-- 1 ari ari 6,0M mar  5 16:16 9-XLSX2XML_fields.xsl.xml
-rw-r--r-- 1 ari ari 5,7M mar  5 16:16 10-EXC2XI_course.xsl.xml
-rw-r--r-- 1 ari ari 5,7M mar  5 16:16 11-EXC2XI_content-fields.xsl.xml
-rw-r--r-- 1 ari ari 5,7M mar  5 16:16 12-EXC2XI_course-links.xsl.xml
-rw-r--r-- 1 ari ari 5,5M mar  5 16:16 13-EXC2XI_categories.xsl.xml
-rw-r--r-- 1 ari ari 5,5M mar  5 16:16 14-EXC2XI_exc-locations.xsl.xml
-rw-r--r-- 1 ari ari 5,6M mar  5 16:16 15-EXC2XI_exc-events.xsl.xml
-rw-r--r-- 1 ari ari 5,3M mar  5 16:16 16-EXC2XI_exc-duration.xsl.xml
-rw-r--r-- 1 ari ari 5,3M mar  5 16:16 17-EXC2XI_exc-email.xsl.xml
-rw-r--r-- 1 ari ari 4,4M mar  5 16:16 18-EXC2XI_xi-dedupe.xsl.xml
-rw-r--r-- 1 ari ari 4,4M mar  5 16:16 19-EXC2XI_xi-cleanup.xsl.xml
```

Each file is named after the XSLT that produces it, plus a prefixed ordinal number, except for the very first file, `0-...`. This is a copy of the source file, copied to the debug folder to enable XSpec testing functionality.

Thus, debugging the pipeline is as easy as determining where the problem is by studying the step outputs and then running the corresponding stylesheet on the previous step's output in an XML editor such as oXygen.


## Running Pipelines via eXist-DB

If XProc is not the solution you're looking for, for some strange reason, you can also run an XSLT pipeline from XQuery in eXist-DB.

First, upload your XSLT pipeline folder to eXist. You might want to ease into this by using an [example pipeline](https://github.com/sgmlguru/xslt-pipelines) I've made up, including an input test file, the XSLT manifest, and the actual XSLT stylesheets. This repo has the following structure:

```
xslt-pipelines/
  pipelines/
    test-manifest.xml
  sources/
    input.xml  
  xslt/
    step1.xsl
    step2.xsl
    step3.xsl
    step4.xsl
```

Keep the entire structure as-is and upload everything to a suitable eXist collection.

Then, add a collection for your scripts and copy the XQuery module and test script to it as follows:

```
./
  modules/
    fc-functions.xqm
  test.xquery
```

Finally, update `test.xquery` to use the collections in your eXist-DB installation.

Note that `test.xquery` will only handle a single input file at a time. The script looks like this:

```
xquery version "3.1";

import module namespace fc = "http://www.sgmlguru.org/ns/fc" at "modules/fc-functions.xqm";

let $source := '/db/test/sources/input.xml'
let $manifest-uri := '/db/repos/xslt-pipeline/pipelines/test-manifest.xml'
let $xslt-seq := fc:load-manifest($manifest-uri)
let $debug := true()

return fc:transform(doc($source),$xslt-seq,$debug)
```

Here, `fc:transform(doc($source),$xslt-seq,$debug)` runs the XSLT pipeline as defined by the manifest `/db/repos/xslt-pipeline/pipelines/test-manifest.xml`. If you've kept the test pipeline structure intact, you'll only need to edit `$source` and `$manifest-uri`, above.

**Note that running XSpec tests in XQuery is not supported yet!**
