FROM amazoncorretto:25-jdk
RUN yum update -y && yum install -y wget unzip tar gzip sed findutils
RUN wget https://services.gradle.org/distributions/gradle-9.4.0-bin.zip -O gradle.zip && unzip gradle.zip -d /opt/gradle
ENV GRADLE_PATH=/opt/gradle/gradle-9.4.0
ENV PATH=$PATH:$GRADLE_PATH/bin
WORKDIR /app
RUN gradle init --type java-application --dsl groovy --package com.test.springapp --project-name springapp --no-split-project --no-incubating
RUN ls -laR > /app/result.txt
