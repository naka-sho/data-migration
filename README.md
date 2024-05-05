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

sample.ymlはあくまでサンプルです。