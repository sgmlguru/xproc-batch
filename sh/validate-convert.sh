#!/bin/sh
# PROJECT=`cd $1; pwd`

XSLT_MANIFEST=$1 # Path to XSLT manifest XML
SCH=$2 # Schematron for output
$SOURCES=$3 # Path to sources
$TMP=$4 # Output base
$PUBLIC_ID=$5
$SYSTEM_ID=$6
$XSPEC_MANIFEST=$7 # XSpec manifest file
VERBOSE=$8 # Verbose output? true/false
DEBUG=$9 # Output debug? true/false
DTD_VALIDATE_INPUT=$10 # Validate input
DTD_VALIDATE_OUTPUT=$11 # Validate output
SCH_VALIDATE_OUTPUT=$12 # Validate output with Schematron
RUN_XSPECS=$13 # Run XSpecs - leave to false now!

ROOT=`cd $(dirname $(realpath -s $0))/..; pwd`

MORGANA_HOME=/home/ari/MorganaXProc-IIIse-0.9.16-beta
MORGANA_LIB=$MORGANA_HOME/MorganaXProc-IIIse_lib/*

#Settings for JAVA_AGENT: Only for Java 8 we have to use -javaagent.
JAVA_AGENT=""

JAVA_VER=$(java -version 2>&1 | sed -n ';s/.* version "\(.*\)\.\(.*\)\..*".*/\1\2/p;')

if [ $JAVA_VER = "18" ]
then
	JAVA_AGENT=-javaagent:$MORGANA_HOME/MorganaXProc-IIIse_lib/quasar-core-0.7.9.jar
fi

# All related jars are expected to be in $MORGANA_LIB. For externals jars: Add them to $CLASSPATH
CLASSPATH=$MORGANA_LIB:$MORGANA_HOME/MorganaXProc-IIIse.jar

echo "Running validate-convert.xpl..."

java \
$JAVA_AGENT \
-cp $CLASSPATH com.xml_project.morganaxproc3.XProcEngine \
-config=$MORGANA_HOME/config.xml \
$ROOT/tests/validate-convert.xpl \
-catalogs=$ROOT/catalogs/catalog.xml \
-input:manifest=$XSLT_MANIFEST
-input:sch=$SCH
-option:input-base-uri=$SOURCES
-option:output-base-uri=$TMP/out
-option:reports-dir=$TMP/out
-option:tmp-dir=$TMP
-option:doctype-public=$PUBLIC_ID
-option:doctype-system=$SYSTEM_ID
-option:xspec-manifest-uri=$XSPEC_MANIFEST
-option:verbose=$VERBOSE
-option:debug=$DEBUG
-option:dtd-validate-input=$DTD_VALIDATE_INPUT
-option:dtd-validate-output=$DTD_VALIDATE_OUTPUT
-option:sch-validate-output=$SCH_VALIDATE_OUTPUT
-option:run-xspecs=$RUN_XSPECS

# "$@"
