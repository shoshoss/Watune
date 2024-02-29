# fighter_app

### ■サービス概要
FighterAppは、自分自身や他者に向けて肯定的な応援メッセージを音声で送ることができるプラットフォームです。
ユーザーは自己肯定感を高め、相互のサポートを通じて前向きなコミュニティを形成できると考えています。

### ■ このサービスへの思い・作りたい理由
以前、私は体調を崩し、退職に至りました。その後約一年間、鬱に近い状態で過ごしました。
この時期、自己肯定感の低さに苦しみ、自分自身への感謝がどれほど大切かを痛感しました。
また、周りからの応援が私の力になった経験から、同じようなサポートを他の人にも提供したいと思い、このアプリを開発したいと考えています。

### ■ ユーザー層について
このアプリは、自己肯定感を高めたい人々、ポジティブな変化を求める人々を対象としています。
自己改善に意欲的な個人や、コミュニティのサポートを求める人々にとって、有用なツールです。

### ■サービスの利用イメージ
ユーザーはアプリを使用して、自分の声で応援メッセージを録音し、自分自身や他者と共有できます。
これにより、自己肯定感の向上と相互のサポートを感じ、前向きに取り組めるようになります。

### ■ ユーザーの獲得について
Twitterや知り合い、Runteqのコミュニティを通じてアプリを宣伝します。自己成長やメンタルヘルスに関心があるユーザーグループをターゲットにしています。

### ■ サービスの差別化ポイント・推しポイント
他の自己肯定感向上アプリと異なり、FighterAppはユーザー同士の応援メッセージを重視しています。
また、ユーザーが簡単にメッセージを作成できるテンプレートの提供は、使いやすさを強化しています。

### ■ 機能候補
- **MVPリリース時**: 音声録音・再生機能、ユーザープロファイル、プライバシー設定、基本的なコミュニケーション機能。
- **本リリース時**: グループ共有機能、アナリティクスツール、カスタムテンプレート。

### ■ 機能の実装方針予定
- **音声録音・再生**: Web Audio APIやネイティブの音声録音機能を使用。
- **コミュニケーション機能**: リアルタイムのメッセージングにはWebSocketやFirebaseを利用予定。
- **プライバシー設定**: OAuthやJWTを用いた安全な認証システムの実装。
- **アナリティクス**: Google AnalyticsやFirebase Analyticsを活用したユーザー行動分析。