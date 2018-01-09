FROM openjdk:8

RUN groupadd -r jetty && useradd -r -g jetty jetty

ENV JETTY_VERSION   7.6.21.v20160908
ENV JOLOKIA_VERSION 1.3.7
ENV JETTY_HOME      /opt/jetty
ENV JOLOKIA_HOME    /opt/jolokia

ENV JETTY_URL       http://central.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VERSION}/jetty-distribution-${JETTY_VERSION}.tar.gz
ENV JOLOKIA_URL     http://search.maven.org/remotecontent?filepath=org/jolokia/jolokia-jvm/${JOLOKIA_VERSION}/jolokia-jvm-${JOLOKIA_VERSION}-agent.jar

RUN mkdir -p $JOLOKIA_HOME && \
curl $JOLOKIA_URL -o $JOLOKIA_HOME/jolokia-jvm-agent.jar

RUN mkdir -p $JETTY_HOME && \
curl $JETTY_URL -o /tmp/jetty.tar.gz && \
tar zxvf /tmp/jetty.tar.gz --strip-components=1 -C $JETTY_HOME && \
chown -R jetty:jetty $JETTY_HOME && \
rm /tmp/jetty.tar.gz

ENV JETTY_PORT  8080
ENV JAVA_OPTS   "-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+UseConcMarkSweepGC -Xms256m -Xmx2048m -server -verbose:gc -XX:-OmitStackTraceInFastThrow"
ENV JETTY_OPTS  "-Djetty.port=$JETTY_PORT -Djetty.home=$JETTY_HOME -Dcom.sun.management.jmxremote"
ENV CLASSPATH   "$JETTY_HOME/lib/*:$JETTY_HOME/lib/jsp/*"
ENV JAVA_AGENT  "-javaagent:$JOLOKIA_HOME/jolokia-jvm-agent.jar"

WORKDIR $JETTY_HOME

ADD entrypoint.sh $JETTY_HOME
RUN chmod +x $JETTY_HOME/entrypoint.sh

EXPOSE $JETTY_PORT

ENTRYPOINT ["./entrypoint.sh"]