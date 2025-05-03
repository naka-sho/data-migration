# data migration tool

## 概要

data の migration に embulk を使用したtoolです。
テストデータ挿入に embulk-input-randomj を使っています。

## 環境構築

```shell
make up
```

## 使い方

```shell
docker exec -it embulk bash
embulk gem install embulk -v 0.11.5
embulk gem install msgpack
embulk gem install bundler
embulk gem install liquid
#
embulk gem install embulk-input-randomj
#
embulk gem install embulk-output-postgresql
embulk gem install embulk-output-kafka

embulk run sample.yml
embulk run kafka.yml
```

抽出した結果をPostgreSQLに一旦保存しファイルで出力するとき

```shell
docker exec -it postgres psql -U postgres -d postgres -X -A -t -c "\i /work/test.sql" -o /work/test.txt
```

sample.ymlはあくまでサンプルです。

## Kafka GUI ツール

Kafka メッセージの送受信を確認するために、Kafka UI ツールが組み込まれています。

```shell
make up
```

コマンドでコンテナを起動した後、ブラウザで以下のURLにアクセスしてください：

```
http://localhost:8080
```

このインターフェースから以下のことができます：
- Kafka トピックの閲覧と作成
- メッセージの送受信の確認
- コンシューマーグループの管理
- その他の Kafka 関連の操作
