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
  "/",
  "/shared/_before_login_header.html.erb",
  "/shared/_sidebar.html.erb",
  "/shared/_header.html.erb",
  "/shared/_widget.html.erb",
  "/shared/_login_modal_button.html.erb",
  "/shared/_flash_message.html.erb",
  "/shared/_before_profile_edit_flash.html.erb",
  "/posts/new.html.erb",
  "/profiles/_edit_modal.html.erb",
  "/posts/_edit_form.html.erb",
  "/profiles/_profile_info.html.erb",
  "/posts/new_test.html.erb",
  "/shared/_footer.html.erb",
  "/posts/_posts_list.html.erb",
  "/posts/_index.html.erb",
  "/posts/_show.html.erb",
  "/profiles/_show.html.erb",
  "/notifications/_notification.html.erb",
];

// インストールイベント: サービスワーカーのインストール時に発生
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log("Opened cache");
      return cache.addAll(essentialUrlsToCache).catch((error) => {
        console.error("Failed to cache essential URLs:", error);
      });
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

  // キャッシュしないリソースの処理
  if (noCacheUrls.some((url) => event.request.url.includes(url))) {
    event.respondWith(fetch(event.request, { redirect: "follow" }));
    return;
  }

  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      const fetchPromise = fetch(event.request, { redirect: "follow" })
        .then((networkResponse) => {
          // ネットワークから取得したリソースをキャッシュに保存
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
          // キャッシュされたレスポンスが存在する場合に返す
          return cachedResponse;
        });

      // キャッシュされたレスポンスを返しつつ、バックグラウンドで最新データをフェッチ
      return cachedResponse || fetchPromise;
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
  } else if (event.data.action === "clearProfileCache") {
    caches.open(CACHE_NAME).then((cache) => {
      noCacheUrls.forEach((url) => {
        cache.delete(url);
      });
    });
  } else if (event.data.action === "clearPostCache") {
    caches.open(CACHE_NAME).then((cache) => {
      noCacheUrls.forEach((url) => {
        cache.delete(url);
      });
    });
  }
});
