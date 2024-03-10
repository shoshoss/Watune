// 必要なSDKから関数をインポートします
import { initializeApp } from "firebase/app"; // Firebaseアプリを初期化するための関数
import { getAnalytics } from "firebase/analytics"; // Firebaseアナリティクスを利用するための関数
import { getFirestore } from "firebase/firestore"; // Firestoreデータベースを利用するための関数

// 使用したいFirebase製品のSDKを追加してください。
// 詳細なセットアップ方法は以下のURLを参照してください: https://firebase.google.com/docs/web/setup#available-libraries

// WebアプリのFirebase設定
// Firebase JS SDK v7.20.0以降では、measurementIdはオプショナルです。
const firebaseConfig = {
  apiKey: "ここにあなたのAPIキーを入力してください",
  authDomain: "ここにあなたの認証ドメインを入力してください",
  projectId: "ここにあなたのプロジェクトIDを入力してください",
  storageBucket: "ここにあなたのストレージバケットを入力してください",
  messagingSenderId: "ここにあなたのメッセージングセンダーIDを入力してください",
  appId: "ここにあなたのアプリIDを入力してください",
  measurementId: "ここにあなたの計測IDを入力してください（オプショナル）"
};

// Firebaseを初期化します。
const app = initializeApp(firebaseConfig);
// Firebaseアナリティクスを初期化します。
const analytics = getAnalytics(app);

// Cloud Firestoreを初期化し、サービスへの参照を取得します。
const db = getFirestore(app);

// Cloud Firestoreのインスタンスをデフォルトエクスポートします。
// これにより、他のファイルからこのデータベースインスタンスを簡単にインポートして利用できるようになります。
export default db;