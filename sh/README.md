# Shell Scripts

This folder contains *example shell scripts* to run pipelines in `{$repo}/xproc`:

* `extract-from-xlsx.sh` extracts content from an Excel spreadsheet to an XML file
* `xlsx2xml-poc` extracts content from an Excel spreadsheet to an XML file and then converts that XML to the *XML Import 3.0* format

The shell scripts point out the sources using the option `input-base-uri=file:/home/ari/Documents/projects/findcourses/poc/sources`. Please note that the output paths are different for the two shell scripts: `extract-from-xlsx.sh` extracts Excel spreadsheet content to an output folder `xml`, used as part of the pipeline run by `xlsx2xml-poc.sh`.

The paths should be modified to match your local system.

