const CACHE_NAME = "Watune-cache-v1"; // キャッシュ名
const SESSION_CACHE_NAME = "Watune-session-cache-v1"; // セッション関連のキャッシュ名

// キャッシュする必要がある重要なURLリスト
const essentialUrlsToCache = [
  "/manifest.webmanifest",
  "/about",
  "/waves",
  "/privacy_policy",
  "/terms_of_use",
];

// カテゴリごとの追加URLリスト
const categoryUrlsToCache = [
  `/waves?category=recommended`,
  `/waves?category=music`,
  `/waves?category=app_review`,
  `/waves?category=tech`,
  `/waves?category=child`,
  `/waves?category=favorite`,
  `waves?category=grateful`,
  `/waves?category=blessing`,
  `/waves?category=other`,
  `/waves?category=monologue`,
];

// 追加でキャッシュするURLリスト
const additionalUrlsToCache = [
  "/icon-192.png",
  "/icon-512.png",
  "/apple-touch-icon.png",
];

// キャッシュしないURLリスト
const noCacheUrls = ["/", "/oauth/google", "/oauth/callback"];

// インストールイベント
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log("Opened cache");
      return cache
        .addAll([...essentialUrlsToCache, ...categoryUrlsToCache])
        .catch((error) => {
          console.error("Failed to cache essential URLs:", error);
          [...essentialUrlsToCache, ...categoryUrlsToCache].forEach((url) => {
            cache.add(url).catch((err) => {
              console.error(`Failed to cache ${url}:`, err);
            });
          });
        });
    })
  );
});

// アクティベートイベント
self.addEventListener("activate", (event) => {
  const cacheWhitelist = [CACHE_NAME, SESSION_CACHE_NAME];
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
    // ユーザー固有のリソースをキャッシュ
    caches.open(SESSION_CACHE_NAME).then((cache) => {
      cache.addAll(event.data.urls).catch((error) => {
        console.error("Failed to cache user specific resources:", error);
        event.data.urls.forEach((url) => {
          cache.add(url).catch((err) => {
            console.error(`Failed to cache ${url}:`, err);
          });
        });
      });
    });
  } else if (event.data.action === "cacheAdditionalResources") {
    // 追加のリソースをキャッシュ
    caches.open(CACHE_NAME).then((cache) => {
      cache.addAll(additionalUrlsToCache).catch((error) => {
        console.error("Failed to cache additional resources:", error);
        additionalUrlsToCache.forEach((url) => {
          cache.add(url).catch((err) => {
            console.error(`Failed to cache ${url}:`, err);
          });
        });
      });
    });
  } else if (event.data.action === "skipWaiting") {
    // 待機中のサービスワーカーをアクティブにする
    self.skipWaiting();
  } else if (event.data.action === "cacheAudioFiles") {
    // 音声ファイルをキャッシュ
    caches.open(CACHE_NAME).then((cache) => {
      cache.addAll(event.data.audioUrls).catch((error) => {
        console.error("Failed to cache audio files:", error);
        event.data.audioUrls.forEach((url) => {
          cache.add(url).catch((err) => {
            console.error(`Failed to cache ${url}:`, err);
          });
        });
      });
    });
  }
});
