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
  "/shared/_flash_message.html.erb",
  "/shared/_before_profile_edit_flash.html.erb",
  "/posts/new.html.erb",
  "/profiles/_edit_modal.html.erb", // プロフィール編集モーダル画面
  "/posts/_edit_form.html.erb", // 投稿編集画面
  "/profiles/_profile_info.html.erb", // プロフィール情報もキャッシュしないように追加
  "/posts/new_test.html.erb",
  "/shared/_footer.html.erb",
  "/posts/_index.html.erb",
  "/posts/_show.html.erb",
  "/profiles/_show.html.erb",
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
          // 更新されたリソースをキャッシュしない
          caches.open(CACHE_NAME).then((cache) => {
            cache.delete(event.request); // 古いキャッシュを削除
          });
        }
        return response;
      })
    );
    // バックグラウンドで最新データを取得し、キャッシュを更新
    event.waitUntil(
      fetch(event.request).then((response) => {
        if (response && response.status === 200 && response.type === "basic") {
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, response.clone());
          });
        }
      })
    );
    return;
  }

  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      const fetchPromise = fetch(event.request).then((networkResponse) => {
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
      cache.addAll(additionalUrlsToCache);
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
