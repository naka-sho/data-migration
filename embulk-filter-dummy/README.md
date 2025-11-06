# Embulk Filter Dummy Plugin

Embulk用のダミーフィルタープラグイン（Java実装）

## 概要

これは Embulk のフィルタープラグインのダミー実装です。入力されたレコードを変更せずにそのまま出力します。
Embulk フィルタープラグインの開発の参考やテンプレートとして使用できます。

## 機能

- 入力されたすべてのレコードをそのまま通過させる
- 設定可能なメッセージをログに出力する
- すべての Embulk データ型（boolean, long, double, string, timestamp, json）に対応

## ビルド方法

```bash
cd embulk-filter-dummy
./gradlew build
```

ビルドが成功すると、`build/libs/embulk-filter-dummy-0.1.0.jar` が生成されます。

Gradleがインストールされていない場合は、システムのGradleを使用してビルドできます：

```bash
cd embulk-filter-dummy
gradle build
```

## 使用方法

Embulk の設定ファイルに以下のようにフィルターセクションを追加します：

```yaml
in:
  type: file
  path_prefix: /path/to/input
  parser:
    type: csv
    columns:
      - {name: id, type: long}
      - {name: name, type: string}
      - {name: value, type: double}

filters:
  - type: dummy
    message: "カスタムメッセージ"

out:
  type: stdout
```

## 設定パラメータ

- **message**: ログに出力されるメッセージ（オプション、デフォルト: "Dummy filter applied"）

## 開発

このプラグインは以下の構造で作成されています：

```
embulk-filter-dummy/
├── build.gradle                  # Gradle ビルド設定
├── settings.gradle               # Gradle プロジェクト設定
├── README.md                     # このファイル
└── src/
    └── main/
        ├── java/
        │   └── org/embulk/filter/dummy/
        │       └── DummyFilterPlugin.java  # メインプラグインクラス
        └── resources/
            └── META-INF/
                └── services/
                    └── org.embulk.spi.FilterPlugin  # プラグイン登録ファイル
```

## ライセンス

MIT License
