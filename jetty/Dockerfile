FROM openjdk:8

RUN groupadd -r amelco && useradd -r -g amelco ameclo

ENV ATS_INSTANCE ats
ENV ATS_INSTANCE_LOCATION /app/$ATS_INSTANCE
ENV ATSLOGS_LOCATION $ATS_INSTANCE_LOCATION/ats_logs

ENV JETTY_DEPLOYMENT true
ENV RIG srv1


RUN mkdir -p $ATS_INSTANCE
RUN mkdir -p $ATSLOGS_LOCATION
RUN mkdir -p $ATS_INSTANCE/lib
WORKDIR $ATS_INSTANCE

#??
#COPY jetty/bin/third-party $ATS_INSTANCE/third-party
#COPY system $ATS_INSTANCE/system
