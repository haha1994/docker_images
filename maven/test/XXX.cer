FROM maven:3.8-jdk-8
COPY settings.xml /usr/share/maven/conf

ENV JRE_PATH=$JAVA_HOME/jre
COPY XXX.cer $JRE_PATH/lib/security

RUN $JRE_PATH/bin/keytool -import -trustcacerts -alias XXX -keystore $JRE_PATH/lib/security/cacerts -file $JRE_PATH/lib/security/cacerts/XXX.cer -storepass hashmap -noprompt