#!/bin/sh
#
# shell script to generate installer units from prototypes
#
# Robert Rossmair, 2004-02-16
#
# $Id$

JPP=../../source/prototypes/jpp
CLXOPTIONS="-c -dVisualCLX -dHAS_UNIT_TYPES -uDevelop -uVCL -x../Q"
VCLOPTIONS="-c -dVCL -dMSWINDOWS -uDevelop -uVisualCLX -uHAS_UNIT_LIBC -uUnix -uLinux -uKYLIX -x../"
FILES="JclInstall.pas JediInstallIntf.pas ProductFrames.pas JediInstallerMain.pas"

$JPP $CLXOPTIONS $FILES
$JPP $VCLOPTIONS $FILES

