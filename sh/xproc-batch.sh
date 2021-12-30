#!/bin/sh
PROJECT=`cd $1; pwd`
VERBOSE=$2 # Verbose output? true/false
DEBUG=$3 # Output debug? true/false
ROOT=`cd $(dirname $(realpath -s $0))/..; pwd`
CALABASH=$ROOT/xmlcalabash-1.1.30-99
echo Running conversion and validation of $PROJECT...
	    java \
	    -classpath "$CALABASH/xmlcalabash-1.1.30-99.jar:$CALABASH/lib/Saxon-HE-9.9.1-5.jar:$CALABASH/lib/commons-logging-1.2.jar:$CALABASH/lib/httpclient-4.5.8.jar:$CALABASH/lib/commons-codec-1.11.jar:$CALABASH/lib/commons-io-2.2.jar" \
	    -Dxml.catalog.files="$ROOT/catalogs/catalog.xml" \
	    com.xmlcalabash.drivers.Main \
	    --entity-resolver org.xmlresolver.Resolver \
	    --input manifest=$ROOT/PATH-TO-XSLT-MANIFEST \
	    --input sch=$ROOT/PATH-TO-SCHEMATRON \
	    input-base-uri=$PROJECT/sources \
	    output-base-uri=$PROJECT/tmp/out \
	    reports-dir=$PROJECT/tmp/reports \
	    tmp-dir=$PROJECT/tmp \
	    doctype-system=SYSTEM-ID \
	    doctype-public=PUBLIC-ID \
	    xspec-manifest-uri=$ROOT/PATH-TO-XSPEC-MANIFEST \
	    verbose=$VERBOSE \
	    debug=$DEBUG \
	    dtd-validate-input=false \
	    dtd-validate-output=false \
	    sch-validate-output=false \
	    run-xspecs=false \
	    $ROOT/xproc-batch/xproc/validate-convert.xpl
