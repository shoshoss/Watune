// app/javascript/application.js
import "@hotwired/turbo-rails";
import "controllers";
import * as ActiveStorage from "@rails/activestorage";
ActiveStorage.start();

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
    }, 3000); // 3秒待機してからサービスワーカーを登録
  });
}
