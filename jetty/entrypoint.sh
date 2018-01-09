#!/bin/sh

set -e

echo "java -cp $CLASSPATH $JAVA_OPTS $ATS_OPTS $JAVA_AGENT org.eclipse.jetty.xml.XmlConfiguration $JETTY_HOME/etc/jetty.xml $JETTY_HOME/etc/jetty-deploy.xml $ATS_SERVER/ats-jetty-webapps.xml"

java -cp $CLASSPATH $JAVA_OPTS $JETTY_OPTS $ATS_OPTS $DEBUG_OPTS $JAVA_AGENT org.eclipse.jetty.xml.XmlConfiguration $JETTY_HOME/etc/jetty.xml $JETTY_HOME/etc/jetty-deploy.xml $ATS_SERVER/ats-jetty-webapps.xml