# Salmonia2
OSS（オープンソースソフトウェア）のSalmonia2です。

誰でも簡単にアップデートができます。

## ビルド方法

CocoaPodsを利用しているので導入が必要です。brewなりでインストールしてください。

```
git clone https://github.com/tkgstrator/Salmonia2.git
cd Salmonia2
pod install
```

Salmonia2.xcworkspaceをXCodeでひらいてビルドするだけです。

## 使用しているAPI

### Nintendo Switch Online API
oauthurlとverifierは使いまわしても問題がないため、常に固定値を使っています。

### s2s API
`https://elifessler.com/s2s/api/gen2`

SplatNet2ライブラリで使用しています。

splatoon_tokenを生成するときに必要なfの値を生成するときに必要なハッシュを計算する外部APIです。

### flapg API
`https://flapg.com/ika2/api/login?public`

SplatNet2ライブラリで使用しています。

splatoon_tokenを生成するときに必要なfの値を計算する外部APIです。

### その他API

`https://script.google.com/macros/s/AKfycbyzVfi2BXni9V439fFtRAqQSjXzNxiUSKFFNEjQ7VNNQlCfcCXt/exec`

GETリクエストした場合、2021年1月1日までのシフト情報を返すAPIです。

POSTリクエストした場合、現在のX-Product Versionを返します。

仕様をわけてるのがアホらしいのでそのうち直したいです。起動時にこれらにアクセスして新しいシフトやバージョンがリリースされていないかチェックしています。
