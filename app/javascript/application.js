import "@hotwired/turbo-rails";
import "controllers";
import * as ActiveStorage from "@rails/activestorage";
ActiveStorage.start();

// サービスワーカーを登録するコード
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/service-worker.js").then(
      (registration) => {
        console.log(
          "ServiceWorker registration successful with scope: ",
          registration.scope
        );

        // 新しいサービスワーカーがインストールされた場合に更新を促す
        if (registration.waiting) {
          registration.waiting.postMessage({ action: "skipWaiting" });
        }

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

        // サービスワーカーが登録された後に追加リソースをバックグラウンドでキャッシュ
        navigator.serviceWorker.ready.then((swRegistration) => {
          swRegistration.active.postMessage({
            action: "cacheAdditionalResources",
          });

          // ログインユーザー用の特定のリソースをバックグラウンドでキャッシュ
          const usernameSlug = getUsernameSlug(); // ユーザーのusername_slugを取得
          if (usernameSlug) {
            navigator.serviceWorker.controller.postMessage({
              action: "cacheUserSpecificResources",
              urls: [
                `/profile_show/${usernameSlug}`,
                "/notification_settings/edit",
                `/user_following/${usernameSlug}`,
                `/user_followers/${usernameSlug}`,
              ],
            });
          }
        });
      },
      (error) => {
        console.log("ServiceWorker registration failed: ", error);
      }
    );
  });
}

// フォローやフォロー解除時のイベントリスナーを追加（最適化）
document.addEventListener("turbo:load", () => {
  const container = document.querySelector("#follow-buttons-container");
  if (container) {
    container.removeEventListener("click", handleFollowButtonClick);
    container.addEventListener("click", handleFollowButtonClick);
  }
});

function handleFollowButtonClick(event) {
  const button = event.target.closest(".follow-button");
  if (!button) return;

  if ("serviceWorker" in navigator && navigator.serviceWorker.controller) {
    navigator.serviceWorker.controller.postMessage({
      action: "updateWidget",
    });
  }
}

// 退会処理用のスクリプトを読み込む
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
