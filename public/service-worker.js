const STATIC_CACHE_NAME = "Watune-static-cache-v1"; // 静的リソースのキャッシュ名
const DYNAMIC_CACHE_NAME = "Watune-dynamic-cache-v1"; // 動的リソースのキャッシュ名
const SESSION_CACHE_NAME = "Watune-session-cache-v1"; // セッション関連のキャッシュ名

// 静的リソースのキャッシュ対象
const staticAssetsToCache = [
  // ページURL
  "/top",
  "/about",
  "/privacy_policy",
  "/terms_of_use",
  // 画像ファイル
  "/images/mail-setting-mobile.png",
  "/images/new-post-mobile.png",
  "/ogp.webp",
  "/logo-watune-en.png", // ロゴ画像
  "/logo-watune.png", // ロゴ画像
  "/icon-192.png",
  "/icon-512.png",
  "/apple-touch-icon.png",
  "/favicon.ico",
  "/icon.svg",
  // スタイルシートとJavaScriptファイル
  "https://kit.fontawesome.com/630314d173.js", // FontAwesomeのJavaScript
  "/manifest.webmanifest", // ウェブアプリのマニフェストファイル
];

// 動的リソースのキャッシュ対象
const dynamicUrlsToCache = [
  // カテゴリURL
  `/waves?category=recommended`,
  `/waves?category=music`,
  `/waves?category=praise_gratitude`,
  `/waves?category=skill`,
  `/waves?category=child`,
  `/waves?category=favorite`,
  `/waves?category=other`,
  `/waves?category=monologue`,
];

// キャッシュしないURLリスト
const noCacheUrls = ["/oauth/google", "/oauth/callback"];

// インストールイベント: 静的リソースをキャッシュ
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE_NAME).then((cache) => {
      console.log("静的リソースをキャッシュします");
      return cache.addAll(staticAssetsToCache);
    })
  );
});

// アクティベートイベント: 古いキャッシュを削除して新しいキャッシュを有効にする
self.addEventListener("activate", (event) => {
  const cacheWhitelist = [
    STATIC_CACHE_NAME,
    DYNAMIC_CACHE_NAME,
    SESSION_CACHE_NAME,
  ];
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

// フェッチイベント: 静的リソースはキャッシュから提供し、動的リソースはStale-While-Revalidate戦略を適用
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

  if (staticAssetsToCache.includes(new URL(event.request.url).pathname)) {
    // 静的リソースのキャッシュ戦略
    event.respondWith(
      caches.match(event.request).then((cachedResponse) => {
        return cachedResponse || fetch(event.request);
      })
    );
  } else if (dynamicUrlsToCache.includes(new URL(event.request.url).pathname)) {
    // 動的リソースのキャッシュ戦略（Stale-While-Revalidate）
    event.respondWith(
      caches.match(event.request).then((cachedResponse) => {
        const fetchPromise = fetch(event.request).then((networkResponse) => {
          if (
            networkResponse &&
            networkResponse.status === 200 &&
            networkResponse.type === "basic"
          ) {
            caches.open(DYNAMIC_CACHE_NAME).then((cache) => {
              cache.put(event.request, networkResponse.clone());
            });
          }
          return networkResponse;
        });
        return cachedResponse || fetchPromise;
      })
    );
  } else {
    // 他のリクエストはネットワークから取得
    event.respondWith(fetch(event.request));
  }
});

// メッセージイベント: 動的にキャッシュを追加する処理
self.addEventListener("message", (event) => {
  if (event.data.action === "cacheUserSpecificResources") {
    caches.open(SESSION_CACHE_NAME).then((cache) => {
      cache.addAll(event.data.urls).catch((error) => {
        console.error(
          "ユーザー固有のリソースのキャッシュに失敗しました:",
          error
        );
        event.data.urls.forEach((url) => {
          cache.add(url).catch((err) => {
            console.error(`キャッシュに失敗しました ${url}:`, err);
          });
        });
      });
    });
  } else if (event.data.action === "cacheAdditionalResources") {
    caches.open(DYNAMIC_CACHE_NAME).then((cache) => {
      cache.addAll(dynamicUrlsToCache).catch((error) => {
        console.error("追加リソースのキャッシュに失敗しました:", error);
        dynamicUrlsToCache.forEach((url) => {
          cache.add(url).catch((err) => {
            console.error(`キャッシュに失敗しました ${url}:`, err);
          });
        });
      });
    });
  } else if (event.data.action === "skipWaiting") {
    self.skipWaiting();
  } else if (event.data.action === "cacheAudioFiles") {
    caches.open(DYNAMIC_CACHE_NAME).then((cache) => {
      cache.addAll(event.data.audioUrls).catch((error) => {
        console.error("音声ファイルのキャッシュに失敗しました:", error);
        event.data.audioUrls.forEach((url) => {
          cache.add(url).catch((err) => {
            console.error(`キャッシュに失敗しました ${url}:`, err);
          });
        });
      });
    });
  }
});
