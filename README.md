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
embulk run sample.yml
embulk run kafka.yml
```

抽出した結果をPostgreSQLに一旦保存しファイルで出力するとき

```shell
docker exec -it postgres psql -U postgres -d postgres -X -A -t -c "\i /work/test.sql" -o /work/test.txt
```

sample.ymlはあくまでサンプルです。