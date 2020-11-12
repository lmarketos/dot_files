#!/bin/bash
### /////////////////////////////////////////////////////////////////////////////
###
### @attention
### Copyright &copy; 2012, LOCKHEED MARTIN CORPORATION as an unpublished work.
### All rights reserved. This computer software is PROPRIETARY INFORMATION of
### Lockheed Martin Corporation and shall not be reproduced, disclosed or used
### without written permission of Lockheed Martin Corporation.
###
### //////////////////////////////////////////////////////////////////////////////

declare testOnly=0 priority=1
JAVA_PATH=`pwd`
while [ $# -gt 0 ];
do
  case "$1" in
    -h) cat << EOF
setup-java-in-alternatives.sh [options] [path_to_new_java]
 options:
   -h                 Print this help message
   -j                 Get Java path from JAVA_HOME enviroment variable
   -t                 Only show the update-alternatives commands that would be run
   -p NUM             Set priority number (DEFAULT: 1)
   -v                 Verbose output
   path_to_new_java   Optional path to newly installed Java version (DEFAULT:current directory).

Detailed Instructions:
This installation script adds Oracle's JAVA version into the alternatives list
 for SuSE.  This script has not been tested on Red Hat systems, but is expected
 to work correctly.

 1. Download Oracle's Java RPM version for the given Linux distribution.
 2. Execute the downloaded binary obtained from step 1.
 3. Once the installation is completed, change directories to the install
    location (usually /usr/java/<jdk_version>).
 4. Execute 'install-oracle-java.sh' from the installation directory.
 5. Configure alternatives using 'sudo update-alternatives --config java'
    and 'sudo update-alternatives --config javac'
 6. ???
 7. Profit!
EOF
       exit 0 ;;
    -j) JAVA_PATH=${JAVA_HOME} ; shift ;;
    -t) testOnly=1 ; shift ;;
    -p) shift ; priority=$1 ; shift ;;
    -*) echo "ERROR: Invalid Option \"$1\"" ; exit 1 ;;
    *) JAVA_PATH=$1 ; shift ;;
  esac
done

ALTERNATIVES=`which update-alternatives`
FIND=`which find`
if [ ${testOnly} -eq 1 ]; then
  SUDO="echo sudo"
else
  SUDO=`which sudo`
fi

JAVAPLUGIN="libnpjp2.so"

JRE_BINS="${JAVA_PATH}/bin/java \
${JAVA_PATH}/bin/rmiregistry \
${JAVA_PATH} \
${JAVA_PATH}/bin/tnameserv \
${JAVA_PATH}/bin/rmid \
${JAVA_PATH}/bin/ControlPanel \
${JAVA_PATH}/bin/policytool \
${JAVA_PATH}/bin/keytool \
${JAVA_PATH}/bin/javaws"

JDK_BINS="${JAVA_PATH}/bin/javac \
${JAVA_PATH}/bin/javah \
${JAVA_PATH}/bin/rmic \
${JAVA_PATH} \
${JAVA_PATH}/jre/lib \
${JAVA_PATH}/bin/jar \
${JAVA_PATH}/bin/javadoc \
${JAVA_PATH}/bin/unpack200 \
${JAVA_PATH}/bin/jconsole \
${JAVA_PATH}/bin/apt \
${JAVA_PATH}/bin/native2ascii \
${JAVA_PATH}/bin/jdb \
${JAVA_PATH}/bin/extcheck \
${JAVA_PATH}/bin/appletviewer \
${JAVA_PATH}/bin/pack200 \
${JAVA_PATH}/bin/serialver \
${JAVA_PATH}/bin/jarsigner \
${JAVA_PATH}/bin/javap \
${JAVA_PATH}/bin/idlj"

ISJREOK=1
ISJDKOK=1
## Install the JRE
for bin in ${JRE_BINS}
do
  if [ ! -e "${bin}" ]; then
    echo "ERROR: Unreadable file ${bin} needed for installation."
    ISJREOK=0
  fi
done

if [ 0 -ne ${ISJREOK} ]; then 
  echo  "Installing JRE from ${JAVA_PATH} into alternatives file."
  ${SUDO} ${ALTERNATIVES} --install /usr/bin/java java ${JAVA_PATH}/bin/java ${priority} \
    --slave /usr/bin/rmiregistry rmiregistry ${JAVA_PATH}/bin/rmiregistry \
    --slave /usr/lib64/jvm/jre jre ${JAVA_PATH} \
    --slave /usr/bin/tnameserv tnameserv ${JAVA_PATH}/bin/tnameserv \
    --slave /usr/bin/rmid rmid ${JAVA_PATH}/bin/rmid \
    --slave /usr/bin/ControlPanel ControlPanel  ${JAVA_PATH}/bin/ControlPanel \
    --slave /usr/bin/policytool policytool  ${JAVA_PATH}/bin/policytool \
    --slave /usr/bin/keytool keytool ${JAVA_PATH}/bin/keytool \
    --slave /usr/share/javaws javaws ${JAVA_PATH}/bin/javaws
  if [ "0" -eq "$?" ]; then
    echo  "JRE alternative installed.  Now execute \"$SUDO $ALTERNATIVES --config java\" to select the active alternative."
  else
    echo "ERROR: JRE alternative installation failed."
    exit $?
  fi
else
  exit 1
fi

## Install the Java plugin for web browser
JAVAPLUGIN_PATH=`${FIND} ${JAVA_PATH} -type f -name ${JAVAPLUGIN}`
if [ -n "${JAVAPLUGIN_PATH}" ]; then
  ${SUDO} ${ALTERNATIVES} --install /usr/lib/browser-plugins/javaplugin.so javaplugin ${JAVAPLUGIN_PATH} ${priority}
  if [ "0" -eq "$?" ]; then
    echo  "Java Plugin alternative installed.  Now execute \"$SUDO $ALTERNATIVES --config javaplugin\" to select the active alternative."
  fi
fi

# Install the JDK, if it also exists
for bin in ${JDK_BINS}
do
  if [ ! -e "$bin" ]; then
    ISJDKOK=0
  fi
done
if [ 0 -ne $ISJDKOK ]; then 
  echo  "Installing JDK from ${JAVA_PATH} into alternatives file."
  ${SUDO} ${ALTERNATIVES} --install /usr/bin/javac javac ${JAVA_PATH}/bin/javac ${priority} \
    --slave /usr/bin/javah javah ${JAVA_PATH}/bin/javah \
    --slave /usr/bin/rmic rmic ${JAVA_PATH}/bin/rmic \
    --slave /usr/lib64/jvm/java java_sdk ${JAVA_PATH} \
    --slave /usr/lib64/jvm-exports/java java_sdk_exports ${JAVA_PATH}/jre/lib \
    --slave /usr/bin/jar jar ${JAVA_PATH}/bin/jar \
    --slave /usr/bin/javadoc javadoc ${JAVA_PATH}/bin/javadoc \
    --slave /usr/bin/unpack200 unpack200 ${JAVA_PATH}/bin/unpack200 \
    --slave /usr/bin/jconsole jconsole ${JAVA_PATH}/bin/jconsole \
    --slave /usr/bin/apt apt ${JAVA_PATH}/bin/apt \
    --slave /usr/bin/native2ascii native2ascii ${JAVA_PATH}/bin/native2ascii \
    --slave /usr/bin/jdb jdb ${JAVA_PATH}/bin/jdb \
    --slave /usr/bin/extcheck extcheck ${JAVA_PATH}/bin/extcheck \
    --slave /usr/bin/appletviewer appletviewer ${JAVA_PATH}/bin/appletviewer \
    --slave /usr/bin/pack200 pack200 ${JAVA_PATH}/bin/pack200 \
    --slave /usr/bin/serialver serialver ${JAVA_PATH}/bin/serialver \
    --slave /usr/bin/jarsigner jarsigner ${JAVA_PATH}/bin/jarsigner \
    --slave /usr/bin/javap javap ${JAVA_PATH}/bin/javap \
    --slave /usr/bin/idlj idlj ${JAVA_PATH}/bin/idlj
  if [ "0" -eq "$?" ]; then
    echo  "JDK alternative installed.  Now execute \"$SUDO $ALTERNATIVES --config javac\" to select the active alternative."
  else
    echo "ERROR: JDK alternative installation failed."
    exit $?
  fi
fi

