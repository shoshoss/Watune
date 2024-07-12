const CACHE_NAME = "Watune-cache-v1"; // キャッシュ名
const SESSION_CACHE_NAME = "Watune-session-cache-v1"; // セッション関連のキャッシュ名

// バックグラウンドでキャッシュする追加URLリスト（共通リソース）
const additionalUrlsToCache = [
  // ページURL
  "/top",
  "/about",
  "/waves",
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

// インストールイベント: キャッシュの設定を行わない
self.addEventListener("install", (event) => {
  console.log("Service Worker がインストールされました");
});

// アクティベートイベント: 古いキャッシュを削除して新しいキャッシュを有効にする
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

// フェッチイベント: リクエストごとにキャッシュを確認し、必要に応じて更新
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

  // Stale While Revalidate 戦略の実装
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
          console.error("フェッチに失敗しました:", error);
        });

      // キャッシュがあればキャッシュを返し、同時にバックグラウンドで更新
      return cachedResponse || fetchPromise;
    })
  );
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
    caches.open(CACHE_NAME).then((cache) => {
      cache.addAll(additionalUrlsToCache).catch((error) => {
        console.error("追加リソースのキャッシュに失敗しました:", error);
        additionalUrlsToCache.forEach((url) => {
          cache.add(url).catch((err) => {
            console.error(`キャッシュに失敗しました ${url}:`, err);
          });
        });
      });
    });
  } else if (event.data.action === "skipWaiting") {
    self.skipWaiting();
  } else if (event.data.action === "cacheAudioFiles") {
    caches.open(CACHE_NAME).then((cache) => {
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
