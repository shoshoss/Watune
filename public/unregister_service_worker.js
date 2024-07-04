if ("serviceWorker" in navigator) {
  navigator.serviceWorker.getRegistrations().then((registrations) => {
    for (let registration of registrations) {
      registration.unregister();
    }
  });
}

// 退会処理を行う関数
function handleAccountDeletion(event) {
  event.preventDefault();
  if (confirm("本当に退会しますか（アカウントの削除）？")) {
    if ("serviceWorker" in navigator) {
      navigator.serviceWorker
        .getRegistrations()
        .then((registrations) => {
          for (let registration of registrations) {
            registration.unregister();
          }
        })
        .finally(() => {
          // セッション関連のキャッシュを削除
          caches
            .keys()
            .then((cacheNames) => {
              cacheNames.forEach((cacheName) => {
                if (cacheName.includes("session-cache")) {
                  caches.delete(cacheName);
                }
              });
            })
            .finally(() => {
              // サービスワーカーの解除とキャッシュ削除が完了した後にリダイレクトを実行
              event.target.closest("form").submit();
            });
        });
    } else {
      // セッション関連のキャッシュを削除
      caches
        .keys()
        .then((cacheNames) => {
          cacheNames.forEach((cacheName) => {
            if (cacheName.includes("session-cache")) {
              caches.delete(cacheName);
            }
          });
        })
        .finally(() => {
          // キャッシュ削除が完了した後にリダイレクトを実行
          event.target.closest("form").submit();
        });
    }
  }
}

// ドキュメントが読み込まれた後、退会リンクにイベントリスナーを追加
document.addEventListener("DOMContentLoaded", () => {
  const deleteAccountLink = document.querySelector(
    'a[data-turbo-method="delete"][data-turbo-confirm]'
  );
  if (deleteAccountLink) {
    deleteAccountLink.addEventListener("click", handleAccountDeletion);
  }
});
