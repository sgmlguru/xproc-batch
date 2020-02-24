# README

This contains XProc and XSLT scripts to convert XML to XML in batch. It is based on Nic Gibson's XProc Tools (inluded here for convenience) and previous work by yours truly.

In addition to the tools here, you'll need a *manifest file* listing your XSLT steps, as well as the XSLT stylesheets themselves. The manifest is an XML file adhering to `xproc-tools/schemas/manifest.rng`.


## Requirements

At the moment, you'll need a recent version of XML Calabash 1.x.x.


## Running

Normally, you'll want to run the XProc script `xproc/validate-convert.xpl` or something that calls it using a shell script that sets up your conversion inputs and options. It's possible to run it from *oXygen*, too, of course.

For example, let's assume that this repository lives at `/home/ari/Documents/repos/xproc-batch` and the repository with the XSLT manifest and stylesheets live at `/home/ari/Documents/repos/xlsx2xml`. Furthermore, there is a project folder on the local PC containing the actual sources files to be converted at `/home/ari/Documents/projects/colleges/sources`.

This shell script would then convert the source files (in this case, some Excel spreadsheets):

```
#!/bin/sh
echo Converting XLSX sources to XML...
        java -classpath "/home/ari/xmlcalabash-1.1.30-99/xmlcalabash-1.1.30-99.jar:/home/ari/xmlcalabash-1.1.30-99/lib/Saxon-HE-9.9.1-5.jar:/home/ari/xmlcalabash-1.1.30-99/lib/commons-logging-1.2.jar:/home/ari/xmlcalabash-1.1.30-99/lib/httpclient-4.5.8.jar:/home/ari/xmlcalabash-1.1.30-99/lib/commons-codec-1.11.jar:/home/ari/xmlcalabash-1.1.30-99/lib/commons-io-2.2.jar" -Dxml.catalog.files="/home/ari/Documents/repos/xproc-batch/catalogs/catalog.xml" com.xmlcalabash.drivers.Main --entity-resolver org.xmlresolver.Resolver --input manifest=file:/home/ari/Documents/repos/xlsx2xml/pipelines/poc/poc-xlsx2xml-manifest.xml --input sch=/home/ari/Documents/repos/xlsx2xml/sch/placeholder.sch input-base-uri=file:/home/ari/Documents/projects/colleges/poc/sources output-base-uri=/home/ari/Documents/projects/colleges/poc/tmp/out reports-dir=/home/ari/Documents/projects/colleges/poc/tmp/reports tmp-dir=/home/ari/Documents/projects/colleges/poc/tmp xspec-manifest-uri=file:/path/to/xspec-manifest.xml verbose=true debug=true dtd-validate-input=false dtd-validate-output=false sch-validate-input=false sch-validate-output=false run-xspecs=false extract-xlsx=true /home/ari/Documents/repos/xproc-batch/xproc/xlsx2xml.xpl

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

You might also want the output to validate against a DTD. Adding `doctype-public` or `doctype-system` (or both) will add a `DOCTYPE` declaration to the output.

Given the above, the XProc script will add an output structure like so:

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


