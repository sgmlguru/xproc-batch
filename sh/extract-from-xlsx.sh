#!/bin/sh
echo Extracting and normalising xlsx archives...
	    java -classpath "/home/ari/xmlcalabash-1.1.30-99/xmlcalabash-1.1.30-99.jar:/home/ari/xmlcalabash-1.1.30-99/lib/Saxon-HE-9.9.1-5.jar:/home/ari/xmlcalabash-1.1.30-99/lib/commons-logging-1.2.jar:/home/ari/xmlcalabash-1.1.30-99/lib/httpclient-4.5.8.jar:/home/ari/xmlcalabash-1.1.30-99/lib/commons-codec-1.11.jar:/home/ari/xmlcalabash-1.1.30-99/lib/commons-io-2.2.jar" -Dxml.catalog.files="/home/ari/Documents/repos/xproc-batch/catalogs/catalog.xml" com.xmlcalabash.drivers.Main --entity-resolver org.xmlresolver.Resolver input-base-uri=file:/home/ari/Documents/projects/findcourses/poc/sources output-base-uri=/home/ari/Documents/projects/findcourses/poc/tmp/xml verbose=true debug=false /home/ari/Documents/repos/xproc-batch/xproc/extract-from-xlsx.xpl