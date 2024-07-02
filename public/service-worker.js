// キャッシュ名とキャッシュするURLを定義
const CACHE_NAME = "Watune-cache-v1";
const essentialUrlsToCache = [
  "/manifest.webmanifest", // 初期読み込み時に必要な最低限のリソース
  "/about", // その他の静的ページをキャッシュ
  "/privacy_policy",
  "/terms_of_use",
];

const additionalUrlsToCache = [
  "/icon-192.png",
  "/icon-512.png",
  "/apple-touch-icon.png",
];

// キャッシュしないリソースを定義
const noCacheUrls = [
  "/", // ルートパスをキャッシュしない
  "/oauth/google", // Google OAuth 認証用のパスをキャッシュしない
  "/oauth/callback", // OAuthコールバックパスをキャッシュしない
  "/notifications/unread_count", // 通知の数を取得するパスをキャッシュしない
];

// インストールイベント: サービスワーカーのインストール時に発生
self.addEventListener("install", (event) => {
  event.waitUntil(
    // キャッシュを開き、必須リソースをキャッシュする
    caches
      .open(CACHE_NAME)
      .then((cache) => {
        console.log("Opened cache");
        return cache.addAll(essentialUrlsToCache);
      })
      .catch((error) => {
        console.error("Failed to cache essential URLs:", error);
      })
  );
});

// アクティベートイベント: サービスワーカーのアクティベート時に発生
self.addEventListener("activate", (event) => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
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

  // OAuth認証用のパスとコールバックパスをバイパス
  if (
    event.request.url.includes("/oauth/google") ||
    event.request.url.includes("/oauth/callback")
  ) {
    event.respondWith(fetch(event.request));
    return;
  }

  // キャッシュしないリソースの処理
  if (noCacheUrls.some((url) => event.request.url.includes(url))) {
    event.respondWith(fetch(event.request));
    return;
  }

  event.respondWith(
    caches
      .match(event.request)
      .then((cachedResponse) => {
        if (cachedResponse) {
          return cachedResponse;
        }
        return fetch(event.request, { redirect: "follow" }).then(
          (networkResponse) => {
            if (
              networkResponse &&
              networkResponse.status === 200 &&
              networkResponse.type === "basic"
            ) {
              const responseToCache = networkResponse.clone();
              caches.open(CACHE_NAME).then((cache) => {
                cache.put(event.request, responseToCache);
              });
            }
            return networkResponse;
          }
        );
      })
      .catch((error) => {
        console.error("Fetch failed:", error);
      })
  );
});

// バックグラウンドで追加リソースをキャッシュ
self.addEventListener("message", (event) => {
  if (event.data.action === "cacheAdditionalResources") {
    caches.open(CACHE_NAME).then((cache) => {
      cache.addAll(additionalUrlsToCache).catch((error) => {
        console.error("Failed to cache additional resources:", error);
      });
    });
  } else if (event.data.action === "skipWaiting") {
    self.skipWaiting();
  }
});
