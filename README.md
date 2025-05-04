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

## Apache SeaTunnel を使用して Kafka からデータを処理する

Apache SeaTunnel は専用のコンテナで実行されます。Kafka から受信したメッセージを処理し、purchase に 10% の税率を計算して your_table_name テーブルと output_seatunnel テーブルに挿入するには、以下のコマンドを実行します：

```shell
docker exec -it seatunnel bash
seatunnel --config /work/seatunnel-config.conf --master local
```

> **注意**: SeaTunnel の実行に必要な依存関係（jersey-client、jersey-core、jsr311-api）がDockerfileに含まれています。これらは `NoClassDefFoundError: com/sun/jersey/client/impl/CopyOnWriteHashMap` エラーを解決するために追加されました。
>
> また、PostgreSQL JDBC ドライバー（postgresql-42.7.2.jar）が SeaTunnel のクラスパスに配置されています。これは `java.lang.ClassNotFoundException: org.postgresql.Driver` エラーを解決するために必要です。
>
> Kafka からメッセージを正しく読み込むために、以下の設定が seatunnel-config.conf に追加されています：
> - `consumer.group.id = "seatunnel-consumer-group"` - Kafka コンシューマーグループを指定
> - `consumer.auto.offset.reset = "earliest"` - トピックの先頭からメッセージを読み込む
> - `consumer.enable.auto.commit = "true"` - オフセットの自動コミットを有効化
> - `consumer.poll.timeout = "5000"` - レコードのポーリングタイムアウトを5000msに設定
> - `option.ignoreParseErrors = "true"` - パースエラーを無視して処理を継続
>
> データベースへの挿入を確実に行うために、以下の設定も追加されています：
> - フィールド名の一貫性を確保（`purchase_date` → `purchase`）- フィールド名とテーブルのカラム名を一致させる
> - `batch_size = 1000` - バッチモードでの挿入を有効化して性能を向上
> - `max_retries = 3` - 挿入失敗時に最大3回再試行

このコマンドは以下の処理を行います：
1. Kafka トピック "quickstart-events" からメッセージを読み込む
2. account フィールドに 10% の税率を計算する
3. 処理したデータを PostgreSQL の your_table_name テーブルに挿入する
4. 処理したデータを PostgreSQL の output_seatunnel テーブルに挿入する（id, account, time, purchase, comment, tax_amount フィールドを含む）

## 自動テスト実行

以下のコマンドを実行すると、環境構築から Kafka へのデータ送信、SeaTunnel による処理、PostgreSQL への挿入までを自動的に行います：

```shell
make test-seatunnel
```

このコマンドは以下の処理を行います：
1. Docker コンテナ（Embulk、SeaTunnel、PostgreSQL、Kafka など）を起動する
2. Embulk の必要なプラグインをインストールする
3. Embulk を使用して CSV データを Kafka に送信する
4. 専用の SeaTunnel コンテナを使用して Kafka からデータを読み込み、税率計算を行い、PostgreSQL に挿入する
5. 結果を確認するために PostgreSQL の your_table_name テーブルと output_seatunnel テーブルからデータを取得する

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
