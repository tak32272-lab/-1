# セキュリティテスト シミュレーター (Android)

自分の自作ゲームの課金セキュリティをテストするための、シミュレーション専用アプリです。
実際のアプリを変更・パッチする機能はありません。

## 機能
- テスト対象ゲーム一覧（全て FREE / ¥0、isFree = true 表示のシミュレーション）
- 自分のゲームを名前で追加
- 防御設定の ON/OFF（サーバー側レシート検証、ローカルフラグ不信、署名チェック、価格照合、セーブ署名）
- パッチ・シミュレーション：5つの改ざんシナリオに対する BLOCK 判定と耐性スコア、対策表示
- 段階テストラボ：Stage 0（設計）〜 Stage 3（プレ本番）、APK が無くても使える
- テストランナー：5シナリオの手順・検知ログ記録・結果入力と PASS/FAIL 自動判定
- テスト記録を .txt でエクスポート

## 構成
- ネイティブ側は WebView 1画面のみ（`MainActivity.java`）
- 実装本体は `app/src/main/assets/index.html`（HTML/JS、localStorage 保存）

## ビルド
```
gradle assembleDebug
# 出力: app/build/outputs/apk/debug/app-debug.apk
```
- パッケージ名: `com.ke.sectest`
- minSdk 26 / targetSdk 34
