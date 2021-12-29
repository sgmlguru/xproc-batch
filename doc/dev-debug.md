# Developing and Debugging XSLT Pipelines

This is a writeup on how to develop and debug XSLT pipelines.


## Basics

The whole pipelining approach is about running XSLT transformations in sequence - step 1 output providing the input to step 2, step 2 output providing the input to step 3, and so on. This has a couple of implications:

* Focus on one thing at a time, regardless of the number of things you need to focus on. You can add as many steps to your pipeline as you want.
* A simple thing means a simple XSLT step.
* It's much easier to add temporary markup to your processing - just do a cleanup step later, when you're done.
* What you do to process your "thing" is much more visible than in a monolithic XSLT (where you'd likely use more variables to store your various temporary constructs and intermediate results).
* As it's all more visible, it's also easier to test and debug. Simply use output from a previous step to process your current one. Look for your erroneous output starting in an intermediate step that processes that approximate "loaction" or "thing". Etc.

And let me just repeat this: *A simple thing means a simple XSLT step.*

The temptation will always be to add just a little bit more to any XSLT that is really just an ID transform and a single template, but *don't,* not if that XSLT does what it's suposed to.


## Pipeline Design

Again: *A simple thing means a simple XSLT step.*

XSLT stylesheets in a pipelined XSLT transformation are cheap. You can have as many as you like, you can easily move them around, and you can easily turn a step off to see what happens without it. This means that refactoring is easy, but also that testing is easy.

Me, I try very hard to start writing a step by writing its unit test, no matter how easy the step is. I use Jeni Tennison's XSpec (TBA link), which, it feels to me, was designed for this very purpose.

An XSpec scenario really just allows you to say that given THIS input, THAT should be output when running your stylesheet. It's like a specification, which is extremely helpful when you have 32 steps and you're about to reorder steps - you can use the XSpec unit tests to ensure that your reorganisation doesn't cause issues.

XProc Batch allows you to define a test manifest to run alongside your XSLT manifest, to run the unit tests in the order you run the steps in, so you can see if the steps run together still do what you thought they would.

Interestingly, I've found that they mostly do, decreasing the need to run the full battery of tests. Funny how writing more tests brings down the need to test.


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


## Example Pipeline

I've created an [example pipeline](https://github.com/sgmlguru/xslt-pipelines) to illustrate how this all works. It's a separate repository, so go ahead and download it next to this one. 

The repo has the following structure:

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
  tests/
  	test-xspec-manifest.xml
  xspec/
  	step1.xspec
  	step4.xspec
```

If you download the xslt-pipelines repo so its root folder is a sibling to the folder you're in right now, the `sh/example.sh` shell script will illustrate a use case. In the current folder, just run

```
sh sh/example.sh ../xslt-pipelines/ true true
```

This is going to clutter the `xslt-pipeline` example repository with a `tmp` folder that contains the example pipeline's output, including a `debug` folder.

The first 'true' tells the pipeline to do verbose output (essentially various messages along the way), and the second to save debug output from each step.

A couple of noteworthy things:

* Running XSpec tests on eXist-db is not supported
* Running XSpec tests via XProc assumes debug=true as it relies on processing file inputs and outputs

