FROM openjdk:8-buster
WORKDIR /root
ENV OPENSSL_CONF /etc/ssl/
ADD SenchaCmd-7.1.0.15-linux-amd64.sh.zip
RUN unzip ./SenchaCmd-7.1.0.15-linux-amd64.sh.zip
RUN ./SenchaCmd-7.1.0.15-linux-amd64.sh -q && ln -s /root/bin/Sencha/Cmd/sencha /usr/bin/sencha
CMD ["/bin/bash"]