# README

This contains a number of XProc scripts to convert stuff in batch from one XML format to another. There are also XProc library steps to extract info from Word and Excel zip archives, and to validate XML.

The XProc relies on Nic Gibson's XProc Tools to do the conversions.


## batch-convert.xpl

XProc library step for batch conversions.


## docx2xml.xpl

XProc pipeline to extract Word ML content from a docx archive in an input base URI, normalise it, and convert it to XML using a pipeline manifest.


## extract-from-docx.xpl

XProc library step to extract content from a docx archive.


## extract-from-xlsx.xpl

XProc library step to extract content from an xlsx archive.


## save-debug.xpl

XProc library step for saving debug output in XSLT manifest conversions.


## validate-convert.xpl

XProc pipeline for converting and validating a batch of XML documents.


## validate-input.xpl

XProc library step for validating XML input against a DTD.


## validate-with-schematron.xpl

XProc library step for validating XML input against a Schematron.


## xlsx2xml.xpl

XProc pipeline to extract Spreadsheet ML content from an xlsx archive in an input base URI, normalise it, and convert it to XML using a pipeline manifest.



