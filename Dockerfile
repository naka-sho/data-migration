FROM openjdk:8

ENV TZ=Asia/Tokyo
COPY embulk-0.11.5.jar /usr/local/bin/embulk
COPY postgresql-42.7.2.jar /opt/postgresql-42.7.2.jar
COPY embulk.properties /root/.embulk/embulk.properties

RUN chmod 755 /usr/local/bin/embulk

WORKDIR /work

ENTRYPOINT ["tail", "-f", "/dev/null"]
