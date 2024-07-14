const STATIC_CACHE_NAME = "Watune-static-cache-v2"; // 静的リソースのキャッシュ名（バージョンを更新）
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
];

// キャッシュしないURLリスト
const noCacheUrls = ["/oauth/google", "/oauth/callback", "/waves"];

// インストールイベント: 静的および動的リソースをキャッシュ
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE_NAME).then((cache) => {
      console.log("静的および動的リソースをキャッシュします");
      return cache.addAll([...staticAssetsToCache, ...dynamicUrlsToCache]);
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

// フェッチイベント: 静的および動的リソースはキャッシュから提供し、バックグラウンドでフェッチして更新
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

  // Stale-While-Revalidate 戦略を使用して動的リソースをキャッシュ
  if (dynamicUrlsToCache.includes(new URL(event.request.url).pathname)) {
    event.respondWith(
      caches.match(event.request).then((cachedResponse) => {
        // キャッシュにリクエストに対応するレスポンスがある場合
        if (cachedResponse) {
          // キャッシュからレスポンスを返す
          fetch(event.request).then((networkResponse) => {
            // ネットワークからのレスポンスが正常な場合
            if (
              networkResponse &&
              networkResponse.status === 200 &&
              networkResponse.type === "basic"
            ) {
              caches.open(DYNAMIC_CACHE_NAME).then((cache) => {
                // ネットワークからのレスポンスをキャッシュに保存
                cache.put(event.request, networkResponse.clone());
              });
            }
          });
          return cachedResponse;
        }

        // キャッシュにリクエストに対応するレスポンスがない場合
        return fetch(event.request).then((networkResponse) => {
          // ネットワークからのレスポンスが正常な場合
          if (
            networkResponse &&
            networkResponse.status === 200 &&
            networkResponse.type === "basic"
          ) {
            caches.open(DYNAMIC_CACHE_NAME).then((cache) => {
              // ネットワークからのレスポンスをキャッシュに保存
              cache.put(event.request, networkResponse.clone());
            });
          }
          // ネットワークからのレスポンスを返す
          return networkResponse;
        });
      })
    );
  } else {
    // 静的リソースのキャッシュ戦略: キャッシュから提供し、キャッシュがなければネットワークから取得
    event.respondWith(
      caches.match(event.request).then((cachedResponse) => {
        return cachedResponse || fetch(event.request);
      })
    );
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
