// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import * as ActiveStorage from "@rails/activestorage";
ActiveStorage.start();

document.addEventListener("DOMContentLoaded", function () {
  const paginationLink = document.getElementById("pagination-link");

  if (!paginationLink) return;

  var intersectionObserver = new IntersectionObserver(
    function (entries) {
      // エントリーが見えるかどうかをチェック
      if (entries[0].isIntersecting) {
        // リンクをクリック
        paginationLink.click();
      }
    },
    {
      rootMargin: "0px",
      threshold: 1.0, // 全部見えている時だけ反応させる
    }
  );

  // リンクを監視
  intersectionObserver.observe(paginationLink);
});
