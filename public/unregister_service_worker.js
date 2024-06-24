// public/unregister_service_worker.js
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
          // サービスワーカーの解除が完了した後にリダイレクトを実行
          event.target.closest("form").submit();
        });
    } else {
      event.target.closest("form").submit();
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
