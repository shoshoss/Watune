// キャッシュ名を定義
const STATIC_CACHE_NAME = "Watune-static-cache-v2"; // 静的リソースのキャッシュ名（バージョンを更新）
const DYNAMIC_CACHE_NAME = "Watune-dynamic-cache-v1"; // 動的リソースのキャッシュ名
const SESSION_CACHE_NAME = "Watune-session-cache-v1"; // セッション関連のキャッシュ名

// 静的リソースのキャッシュ対象
const staticAssetsToCache = [
  "/top",
  "/about",
  "/privacy_policy",
  "/terms_of_use", // ページURL
  "/images/mail-setting-mobile.png",
  "/images/new-post-mobile.png", // 画像ファイル
  "/ogp.webp",
  "/logo-watune-en.png",
  "/logo-watune.png", // ロゴ画像
  "/icon-192.png",
  "/icon-512.png",
  "/apple-touch-icon.png",
  "/favicon.ico",
  "/icon.svg", // アイコン
  "https://kit.fontawesome.com/630314d173.js", // FontAwesomeのJavaScript
  "/manifest.webmanifest", // ウェブアプリのマニフェストファイル
];

// 動的リソースのキャッシュ対象
const dynamicUrlsToCache = [
  `/waves?category=recommended`, // カテゴリURL
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

// フェッチイベント: リクエストをインターセプトしてキャッシュを使用
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
    event.respondWith(
      fetch(event.request).catch((error) => {
        console.error("OAuthリクエストのフェッチに失敗しました:", error);
        throw error;
      })
    );
    return;
  }

  // キャッシュしないリソースの処理
  if (noCacheUrls.some((url) => event.request.url.includes(url))) {
    event.respondWith(
      fetch(event.request).catch((error) => {
        console.error(
          "キャッシュしないリクエストのフェッチに失敗しました:",
          error
        );
        throw error;
      })
    );
    return;
  }

  // 動的リソースのキャッシュ戦略: Stale-While-Revalidate
  if (dynamicUrlsToCache.includes(new URL(event.request.url).pathname)) {
    event.respondWith(
      caches
        .match(event.request)
        .then((cachedResponse) => {
          if (cachedResponse) {
            fetch(event.request)
              .then((networkResponse) => {
                if (
                  networkResponse &&
                  networkResponse.status === 200 &&
                  networkResponse.type === "basic"
                ) {
                  caches
                    .open(DYNAMIC_CACHE_NAME)
                    .then((cache) => {
                      cache.put(event.request, networkResponse.clone());
                    })
                    .catch((error) => {
                      console.error(
                        "動的キャッシュの保存に失敗しました:",
                        error
                      );
                    });
                }
              })
              .catch((error) => {
                console.error("動的リクエストのフェッチに失敗しました:", error);
              });
            return cachedResponse;
          }

          return fetch(event.request)
            .then((networkResponse) => {
              if (
                networkResponse &&
                networkResponse.status === 200 &&
                networkResponse.type === "basic"
              ) {
                caches
                  .open(DYNAMIC_CACHE_NAME)
                  .then((cache) => {
                    cache.put(event.request, networkResponse.clone());
                  })
                  .catch((error) => {
                    console.error("動的キャッシュの保存に失敗しました:", error);
                  });
              }
              return networkResponse;
            })
            .catch((error) => {
              console.error("動的リクエストのフェッチに失敗しました:", error);
            });
        })
        .catch((error) => {
          console.error("キャッシュマッチに失敗しました:", error);
          throw error;
        })
    );
  } else {
    // 静的リソースのキャッシュ戦略: キャッシュから提供し、キャッシュがなければネットワークから取得
    event.respondWith(
      caches
        .match(event.request)
        .then((cachedResponse) => {
          return (
            cachedResponse ||
            fetch(event.request).catch((error) => {
              console.error("静的リクエストのフェッチに失敗しました:", error);
              throw error;
            })
          );
        })
        .catch((error) => {
          console.error("キャッシュマッチに失敗しました:", error);
          throw error;
        })
    );
  }
});

// メッセージイベント: 動的にキャッシュを追加する処理
self.addEventListener("message", (event) => {
  // ユーザー固有のリソースをキャッシュするアクション
  if (event.data.action === "cacheUserSpecificResources") {
    caches.open(SESSION_CACHE_NAME).then((cache) => {
      cache.addAll(event.data.urls).catch((error) => {
        console.error(
          "ユーザー固有のリソースのキャッシュに失敗しました:",
          error
        );
      });
    });
  }
  // 追加のリソースをキャッシュするアクション
  else if (event.data.action === "cacheAdditionalResources") {
    caches.open(DYNAMIC_CACHE_NAME).then((cache) => {
      cache.addAll(dynamicUrlsToCache).catch((error) => {
        console.error("追加リソースのキャッシュに失敗しました:", error);
      });
    });
  }
  // サービスワーカーを即時にアクティベートするアクション
  else if (event.data.action === "skipWaiting") {
    self.skipWaiting();
  }
  // 音声ファイルをキャッシュするアクション
  else if (event.data.action === "cacheAudioFiles") {
    caches.open(DYNAMIC_CACHE_NAME).then((cache) => {
      cache.addAll(event.data.audioUrls).catch((error) => {
        console.error("音声ファイルのキャッシュに失敗しました:", error);
      });
    });
  }
});
