# README

This repository contains XProc and XSLT scripts to run an XSLT-based pipeline converting XML to XML in batch. It is based on Nic Gibson's [XProc Tools](https://github.com/nic-gibson/xproc-tools).

Previous versions of this repo were written in XProc 1.0 and relied on Nic's repo and Norm Walsh's XML Calabash XProc engine. The current version is a rewrite in XProc 3.0, with a forked XProc 3.0 version of XProc Tools and Achim Berndzen's Morgana XProc-IIIse XProc 3.0 engine. It's still a work in progress, and some features do not yet work.

There is also an XQuery module and a test XQuery calling the functions in the module, both intended to run in eXist-DB. These, just like the XProc scripts, are intended to run an XSLT pipeline.

XProc Tools define, and XProc Batch use, a *manifest file* listing your XSLT steps, as well as the XSLT stylesheets themselves. The manifest is an XML file adhering to `xproc-tools/schemas/manifest.rng`.

**Not yet functional in XProc 3.0!** XProc Batch also allows you to run XSpec unit tests you've written for your individual XSLT stylesheets alongside the XSLT pipeline by listing them in an XSpec test manifest file similar to the XSLT manifest. The XSpec manifest format is described in `xspec-tools/rng/xspec-manifest.rnc`.

**XProc 1.0 only!** An example pipeline, complete with a pipeline manifest XSLT stylesheets, a test manifest and XSpec unit test examples, is available at [XSLT Pipelines](https://github.com/sgmlguru/xslt-pipelines).

XProc Batch and XProc Tools both includes a number of test pipelines to check various features and functionality.


## Requirements

You'll need one of the following: 

* **XProc 3.0 only!** [MorganaXProc-IIIse](https://www.xml-project.com/morganaxproc-iii/) in version 0.9.16 or later.
* **XProc 1.0 only!** A recent version of [XML Calabash 1.x.x](https://xmlcalabash.com/). Morgana XProc 1.x won't work because the XProc scripts rely on Calabash extensions.
* An [eXist-DB XML database](http://exist-db.org/exist/apps/homepage/index.html), version 5.2 or later.


## Running Pipelines via XProc

Normally, you'll want to run the XProc script `xproc/validate-convert.xpl`, or an XProc that calls it, using a shell script that sets up your conversion inputs and options. It's possible to run it from *oXygen*, too, of course. For shell script examples, see `sh/` - `sh/validate-convert.sh` illustrates how to run `xproc/validate-convert.xpl` in XProc 3.0.

For example, let's say this repository lives at `/home/ari/Documents/repos/xproc-batch` and the repository with the XSLT manifest and stylesheets at `/home/ari/Documents/repos/xlsx2xml`. There is also a project folder on the local file system containing sources files to be converted at `/home/ari/Documents/projects/colleges/sources`.

FInally, we'll assume that XML Calabash is unpacked to `/home/ari/xmlcalabash-1.1.30-99/`.

This shell script would then convert the source files (in this case, some Excel spreadsheets) to an XML format:

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
          sch-validate-output=false \
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

Leave out the `--input sch=...` line and you don't have to include a Schematron file. Similarly, leave out `xspec-manifest-uri=...` and you don't have to include an XSpec manifest file.

The XProc script will generate an output structure like so:

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


## Running Pipelines via eXist-DB

If XProc is not your thing, you can also run the XSLT pipeline from XQuery in eXist-DB.

First, upload your XSLT pipeline folder to eXist. You might want to ease into this by using that [example pipeline](https://github.com/sgmlguru/xslt-pipelines) I mentioned above, that includes an input test file, the XSLT manifest, and the actual XSLT stylesheets.

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

import module namespace pipelines = "http://www.sgmlguru.org/ns/pipelines" at "modules/pipeline-functions.xqm";
let $source := '/db/test/sources/input.xml'
let $manifest-uri := '/db/repos/xslt-pipeline/pipelines/test-manifest.xml'
let $xslt-seq := pipelines:load-manifest($manifest-uri)
let $debug := true()

return pipelines:transform(doc($source),$xslt-seq,$debug)
```

Here, `pipelines:transform(doc($source),$xslt-seq,$debug)` runs the XSLT pipeline as defined by the manifest `/db/repos/xslt-pipeline/pipelines/test-manifest.xml`. If you've kept the test pipeline structure intact, you'll only need to edit `$source` and `$manifest-uri`, above.

**Note that running XSpec tests in XQuery is not supported yet!**


## Developing and Debugging

I go into more detail about developing and debugging XSLT pipelines in [a separate document](doc/dev-debug.md).

