// キャッシュ名とキャッシュするURLを定義
const CACHE_NAME = "Watune-cache-v1";
const essentialUrlsToCache = [
  "/manifest.webmanifest", // 初期読み込み時に必要な最低限のリソース
];
const additionalUrlsToCache = [
  "/icon-192.png",
  "/icon-512.png",
  "/apple-touch-icon.png",
];

// キャッシュしないリソースを定義
const noCacheUrls = [
  "/shared/_before_login_header.html.erb",
  "/shared/_sidebar.html.erb",
  "/shared/_header.html.erb",
  "/shared/_widget.html.erb",
  "/shared/_login_modal_button.html.erb",
  "/posts/new.html.erb", // 新規投稿画面をキャッシュしない
];

// インストールイベント: サービスワーカーのインストール時に発生
self.addEventListener("install", (event) => {
  event.waitUntil(
    // キャッシュを開き、必須リソースをキャッシュする
    caches.open(CACHE_NAME).then((cache) => {
      console.log("Opened cache");
      return cache.addAll(essentialUrlsToCache);
    })
  );
});

// アクティベートイベント: サービスワーカーのアクティベート時に発生
self.addEventListener("activate", (event) => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    // 不要な古いキャッシュを削除する
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (!cacheWhitelist.includes(cacheName)) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// フェッチイベント: ネットワークリクエストが発生したときに処理
self.addEventListener("fetch", (event) => {
  // chrome-extension スキームや POST リクエストを除外
  if (
    event.request.url.startsWith("chrome-extension") ||
    event.request.method === "POST"
  ) {
    return;
  }

  // キャッシュしないリソースの処理
  if (noCacheUrls.some((url) => event.request.url.includes(url))) {
    event.respondWith(
      fetch(event.request).then((response) => {
        // 更新されたリソースをキャッシュしない
        if (response && response.status === 200 && response.type === "basic") {
          caches.open(CACHE_NAME).then((cache) => {
            cache.delete(event.request); // 古いキャッシュを削除
          });
        }
        return response;
      })
    );
    return;
  }

  event.respondWith(
    // キャッシュを確認し、キャッシュがあればそれを返す
    caches.match(event.request).then((response) => {
      if (response) {
        return response;
      }
      // キャッシュにない場合は、ネットワークから取得
      return fetch(event.request).then((response) => {
        // ネットワークから取得したリソースをキャッシュに保存
        if (!response || response.status !== 200 || response.type !== "basic") {
          return response;
        }
        const responseToCache = response.clone();
        caches.open(CACHE_NAME).then((cache) => {
          cache.put(event.request, responseToCache);
        });
        return response;
      });
    })
  );
});

// バックグラウンドで追加リソースをキャッシュ
self.addEventListener("message", (event) => {
  if (event.data.action === "cacheAdditionalResources") {
    caches.open(CACHE_NAME).then((cache) => {
      cache.addAll(additionalUrlsToCache);
    });
  } else if (event.data.action === "skipWaiting") {
    self.skipWaiting();
  }
});
