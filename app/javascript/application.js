import "@hotwired/turbo-rails";
import "controllers";
import * as ActiveStorage from "@rails/activestorage";
ActiveStorage.start();

// サービスワーカーを登録するコードを追加
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    setTimeout(() => {
      navigator.serviceWorker.register("/service-worker.js").then(
        (registration) => {
          console.log(
            "ServiceWorker registration successful with scope: ",
            registration.scope
          );
        },
        (error) => {
          console.log("ServiceWorker registration failed: ", error);
        }
      );
    }, 2000);
  });
}

// 退会処理用のスクリプトを読み込む
document.addEventListener("DOMContentLoaded", () => {
  const script = document.createElement("script");
  script.src = "/unregister_service_worker.js";
  document.head.appendChild(script);
});
