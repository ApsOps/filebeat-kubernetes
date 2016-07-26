FROM ubuntu

MAINTAINER Amanpreet Singh <aps.sids@gmail.com>

ENV FILEBEAT_VERSION 1.2.3

RUN apt-get update && \
    apt-get -y install wget && \
    wget http://download.elastic.co/beats/filebeat/filebeat-${FILEBEAT_VERSION}-x86_64.tar.gz && \
    wget https://download.elastic.co/beats/filebeat/filebeat-${FILEBEAT_VERSION}-x86_64.tar.gz.sha1.txt && \
    sha1sum -c filebeat-${FILEBEAT_VERSION}-x86_64.tar.gz.sha1.txt && \
    tar xzf filebeat-${FILEBEAT_VERSION}-x86_64.tar.gz && \
    mv filebeat-${FILEBEAT_VERSION}-x86_64/filebeat /usr/local/bin && \
    rm -rf /filebeat* && \
    apt-get -y remove wget && \
    apt-get -y autoremove

COPY filebeat.yml /etc/filebeat/

CMD ["/usr/local/bin/filebeat", "-e", "-c", "/etc/filebeat/filebeat.yml"]
