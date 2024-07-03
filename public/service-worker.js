// キャッシュ名とキャッシュするURLを定義
const CACHE_NAME = "Watune-cache-v1";
const essentialUrlsToCache = [
  "/manifest.webmanifest",
  "/about",
  "/waves",
  "/privacy_policy",
  "/terms_of_use",
];

const additionalUrlsToCache = [
  "/icon-192.png",
  "/icon-512.png",
  "/apple-touch-icon.png",
];

const noCacheUrls = ["/", "/oauth/google", "/oauth/callback"];

// インストールイベント
self.addEventListener("install", (event) => {
  event.waitUntil(
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

// アクティベートイベント
self.addEventListener("activate", (event) => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (!cacheWhitelist.includes(cacheName)) {
            return caches.delete(cacheName); // 古いキャッシュを削除
          }
        })
      );
    })
  );
});

// フェッチイベント
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

  // キャッシュファースト戦略とStale-While-Revalidate戦略を組み合わせる
  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      const fetchPromise = fetch(event.request, { redirect: "follow" })
        .then((networkResponse) => {
          // ネットワークからのレスポンスをキャッシュに保存
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
        })
        .catch((error) => {
          console.error("Fetch failed:", error);
        });

      // キャッシュがあればキャッシュを返し、同時にバックグラウンドで更新
      return cachedResponse || fetchPromise;
    })
  );
});

// メッセージイベント
self.addEventListener("message", (event) => {
  if (event.data.action === "cacheUserSpecificResources") {
    caches.open(CACHE_NAME).then((cache) => {
      cache.addAll(event.data.urls).catch((error) => {
        console.error("Failed to cache user specific resources:", error);
      });
    });
  } else if (event.data.action === "cacheAdditionalResources") {
    caches.open(CACHE_NAME).then((cache) => {
      cache.addAll(additionalUrlsToCache).catch((error) => {
        console.error("Failed to cache additional resources:", error);
      });
    });
  } else if (event.data.action === "skipWaiting") {
    self.skipWaiting();
  } else if (event.data.action === "cacheAudioFiles") {
    caches.open(CACHE_NAME).then((cache) => {
      cache.addAll(event.data.audioUrls).catch((error) => {
        console.error("Failed to cache audio files:", error);
      });
    });
  }
});
