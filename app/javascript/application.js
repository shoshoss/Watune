// Turbo Railsとコントローラをインポート
import "@hotwired/turbo-rails";
import "controllers";

// Active Storageをインポートしてスタート
import * as ActiveStorage from "@rails/activestorage";
ActiveStorage.start();

// サービスワーカーのサポートをチェック
if ("serviceWorker" in navigator) {
  // ウィンドウがロードされたときにサービスワーカーを登録
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/service-worker.js").then(
      (registration) => {
        console.log(
          "ServiceWorker registration successful with scope: ",
          registration.scope
        );

        // 新しいサービスワーカーが待機状態の場合、skipWaitingメッセージを送信
        if (registration.waiting) {
          registration.waiting.postMessage({ action: "skipWaiting" });
        }

        // 新しいサービスワーカーが見つかった場合の処理
        registration.addEventListener("updatefound", () => {
          const newWorker = registration.installing;
          newWorker.addEventListener("statechange", () => {
            if (
              newWorker.state === "installed" &&
              navigator.serviceWorker.controller
            ) {
              newWorker.postMessage({ action: "skipWaiting" });
            }
          });
        });

        // サービスワーカーが準備完了したら追加リソースをキャッシュ
        navigator.serviceWorker.ready.then((swRegistration) => {
          swRegistration.active.postMessage({
            action: "cacheAdditionalResources",
          });

          // ユーザーのusername_slugを取得してユーザー特定のリソースをキャッシュ
          const usernameSlug = getUsernameSlug();
          if (usernameSlug) {
            if (navigator.serviceWorker.controller) {
              navigator.serviceWorker.controller.postMessage({
                action: "cacheUserSpecificResources",
                urls: [
                  `/${usernameSlug}`,
                  "/notifications",
                  "/notification_settings/edit",
                  `/${usernameSlug}/user_following`,
                  `/${usernameSlug}/user_followers`,
                  `/waves/new`,
                  `/waves/new?privacy=only_me`,
                  `/waves/new?privacy=selected_users`,
                  `/waves/new?privacy=open`,
                ],
              });
            } else {
              console.error("ServiceWorker controller is null");
            }
          }
        });
      },
      (error) => {
        console.log("ServiceWorker registration failed: ", error);
      }
    );
  });
}

// Turboがロードされたときにフォローボタンのイベントリスナーを設定
document.addEventListener("turbo:load", () => {
  const container = document.querySelector("#follow-buttons-container");
  if (container) {
    container.removeEventListener("click", handleFollowButtonClick);
    container.addEventListener("click", handleFollowButtonClick);
  }
});

// フォローボタンがクリックされたときの処理
function handleFollowButtonClick(event) {
  const button = event.target.closest(".follow-button");
  if (!button) return;

  // サービスワーカーがアクティブであればupdateWidgetアクションを送信
  if ("serviceWorker" in navigator && navigator.serviceWorker.controller) {
    navigator.serviceWorker.controller.postMessage({
      action: "updateWidget",
    });
  }
}

// DOMコンテンツが読み込まれたときにサービスワーカーをアンレジスタするスクリプトを読み込む
document.addEventListener("DOMContentLoaded", () => {
  const script = document.createElement("script");
  script.src = "/unregister_service_worker.js";
  document.head.appendChild(script);
});

// ユーザーのusername_slugを取得する関数
function getUsernameSlug() {
  const userDataElement = document.getElementById("user-data");
  return userDataElement ? userDataElement.dataset.usernameSlug : null;
}
