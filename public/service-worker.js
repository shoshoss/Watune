// キャッシュ名とキャッシュするURLを定義
const CACHE_NAME = "Watune-cache-v1";
const essentialUrlsToCache = [
  "/manifest.webmanifest", // 初期読み込み時に必要な最低限のリソース
  "/",
];
const additionalUrlsToCache = [
  "/waves",
  "/icon-192.png",
  "/icon-512.png",
  "/apple-touch-icon.png",
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
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// フェッチイベント: ネットワークリクエストが発生したときに処理
self.addEventListener("fetch", (event) => {
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
