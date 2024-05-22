FROM openjdk:8

ENV TZ=Asia/Tokyo
COPY embulk-0.9.23.jar /usr/local/bin/embulk
COPY postgresql-42.7.2.jar /opt/postgresql-42.7.2.jar

# https://kafka.apache.org/quickstart
# kafkaを使う場合
RUN chmod +x /usr/local/bin/embulk

RUN embulk gem install embulk-input-randomj

RUN embulk gem install embulk-output-postgresql
RUN embulk gem install embulk-output-kafka

WORKDIR /work

ENTRYPOINT ["tail", "-f", "/dev/null"]
