2019年度実験４サンプルコード

釣り班のサンプルコードです．レファレンスまたは，これをベースに開発してもかまいません．
先に提示したクラス図にある程度準拠しています
macOSで開発していますが，SCNSceneRendererはiosと互換のはずなのですんなり移植できるはずです．
taget:fishint_arを参考に（またはベースに）移植するなりしてください．
fishing_arはモーションセンサの値をとるところは記述済みです．

カメラの位置情報と共に，モーションデータをGameStatusのインスタンスに保存して，GameSceneから参照するとよいと思います．
Resultシーンは，storyboardを使ってみました．ここはiosと互換しないので参考程度にどうぞ．（基本的な考え方はiosもmacosも同じです）


操作方法：
　トラックパッドで視点操作（ドラッグ，ピンチなど) -> ARアプリにおいてカメラを動かすことに相当
  何かキーを押す -> iosにおけるタップのシミュレーション
