// Turbo Railsとコントローラをインポート
import "@hotwired/turbo-rails";
import "controllers";

// Active Storageをインポートしてスタート
import * as ActiveStorage from "@rails/activestorage";
ActiveStorage.start();
