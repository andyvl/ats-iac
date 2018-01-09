#!/bin/sh

set -e 

echo "java -cp $CLASSPATH $JETTY_OPTS $JAVA_AGENT org.eclipse.jetty.xml.XmlConfiguration $JETTY_HOME/etc/jetty.xml $JETTY_HOME/etc/jetty-deploy.xml"
java -cp $CLASSPATH $JAVA_OPTS $JETTY_OPTS $JAVA_AGENT org.eclipse.jetty.xml.XmlConfiguration $JETTY_HOME/etc/jetty.xml $JETTY_HOME/etc/jetty-deploy.xml